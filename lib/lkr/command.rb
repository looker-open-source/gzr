# frozen_string_literal: true

require 'forwardable'

require 'pastel'
require 'tty-reader'
require 'netrc'

require 'rubygems'
require 'rubygems/package'
require 'bundler/setup'
require 'looker-sdk'

module Lkr
  class Command
    extend Forwardable

    def initialize
      @sdk = nil
      @access_token_stack = Array.new
      @options = Hash.new
      @pastel = Pastel.new
    end

    def_delegators :command, :run

    # Execute this command
    #
    # @api public
    def execute(*)
      raise(
        NotImplementedError,
        "#{self.class}##{__method__} must be implemented"
      )
    end

    # The external commands runner
    #
    # @see http://www.rubydoc.info/gems/tty-command
    #
    # @api public
    def command(**options)
      require 'tty-command'
      TTY::Command.new(options)
    end

    private

    def say_ok(data)
      puts @pastel.green data
    end

    def say_warning(data)
      puts @pastel.yellow data
    end

    def say_error(data)
      puts @pastel.red data
    end

    def login
      conn_hash = Hash.new
      conn_hash[:api_endpoint] = "http#{@options[:ssl] ? "s" : ""}://#{@options[:host]}:#{@options[:port]}/api/#{@options[:api_version]}"
      conn_hash[:connection_options] = {:ssl => {:verify => @options[:verify_ssl]}} 
      if @options[:client_id] then
        conn_hash[:client_id] = @options[:client_id]
        if @options[:client_secret] then
          conn_hash[:client_secret] = @options[:client_secret]
        else
          conn_hash[:client_secret] = reader.read_line( "Enter your client_secret:", echo: false)
        end
      else
        conn_hash[:netrc] = true
        conn_hash[:netrc_file] = "~/.netrc"
      end

      say_ok("connecting to #{conn_hash.each { |k,v| "#{k}=>#{(k == :client_secret) ? '*********' : v}" }}") if @options[:debug]

      begin
        @sdk = LookerSDK::Client.new(conn_hash) unless @sdk
        say_ok "check for connectivity: #{@sdk.alive?}" if @options[:debug]
        say_ok "verify authentication: #{@sdk.authenticated?}" if @options[:debug]
      rescue LookerSDK::Unauthorized => e
        say_error "Unauthorized - credentials are not valid"
        raise
      rescue LookerSDK::Error => e
        say_error "Unable to connect"
        say_error e.message
        raise
      end
      if @options[:su] then
        say_ok "su to user #{@options[:su]}" if @options[:debug]
        @access_token_stack.push(@sdk.access_token)
        begin
          @sdk.access_token = @sdk.login_user(@options[:su]).access_token
          say_warning "verify authentication: #{@sdk.authenticated?}" if @options[:debug]
        rescue LookerSDK::Error => e
          say_error "Unable to su to user #{@options[:su]}" 
          say_error e.message
          raise
        end
      end
      @sdk
    end

    def logout_all
      pastel = Pastel.new(enabled: true)
      say_ok "logout" if @options[:debug]
      begin
        @sdk.logout
      rescue LookerSDK::Error => e
        say_error "Unable to logout"
        say_error e.message
      end
      loop do
        token = @access_token_stack.pop
        break unless token
        say_ok "logout the parent session" if @options[:debug]
        @sdk.access_token = token
        begin
          @sdk.logout
        rescue LookerSDK::Error => e
          say_error "Unable to logout"
          say_error e.message
        end
      end
    end

    def with_session
      return nil unless block_given?
      begin
        login
        yield
      ensure
        logout_all
      end
    end

    def query_me(fields=nil)
      data = nil
      begin
        data = @sdk.me(fields ? {:fields=>fields} : nil )
      rescue LookerSDK::Error => e
          say_error "Error querying me({:fields=>\"#{fields}\"})"
          say_error e.message
          raise
      end
      data
    end

    def query_user(id,fields=nil)
      data = nil
      begin
        data = @sdk.user(id, fields ? {:fields=>fields} : nil )
      rescue LookerSDK::Error => e
          say_error "Error querying user(#{id},{:fields=>\"#{fields}\"})"
          say_error e.message
          raise
      end
      data
    end

    def search_users(filter, fields=nil, sorts=nil)
      req = {
        :per_page=>128
      }
      req.merge!(filter)
      req[:fields] = fields if fields
      req[:sorts] = sorts if sorts

      data = Array.new
      page = 1
      loop do
        begin
          req[:page] = page
          scratch_data = @sdk.search_users(req)
        rescue LookerSDK::ClientError => e
          say_error "Unable to get search_users(#{JSON.pretty_generate(req)})"
          say_error e.message
          raise
        end
        break if scratch_data.length == 0
        page += 1
        data += scratch_data
      end
      data
    end

    def query_all_users(fields=nil, sorts=nil)
      req = {
        :per_page=>128
      }
      req[:fields] = fields if fields
      req[:sorts] = sorts if sorts

      data = Array.new
      page = 1
      loop do
        begin
          req[:page] = page
          scratch_data = @sdk.all_users(req)
        rescue LookerSDK::ClientError => e
          say_error "Unable to get all_users(#{JSON.pretty_generate(req)})"
          say_error e.message
          raise
        end
        break if scratch_data.length == 0
        page += 1
        data += scratch_data
      end
      data
    end

    def search_spaces(name,fields=nil)
      data = nil
      begin
        req = {:name => name}
        req[:fields] = fields if fields
        data = @sdk.search_spaces(req)
      rescue LookerSDK::Error => e
        say_error "Error querying search_spaces(#{JSON.pretty_generate(req)})"
        say_error e.message
        raise
      end
      data
    end

    def query_space(id,fields=nil)
      data = nil
      begin
        req = {}
        req[:fields] = fields if fields 
        data = @sdk.space(id, req)
      rescue LookerSDK::Error => e
        say_error "Error querying space(#{id},#{JSON.pretty_generate(req)})"
        say_error e.message
        raise
      end
      data
    end

    def process_args(args)
      space_ids = []

      begin
        user = query_me("home_space_id")
        space_ids << user.home_space_id
      end unless args && args.length > 0 && !(args[0].nil?)

      if args[0] =~ /^[0-9]+$/ then
        space_ids << args[0].to_i
      elsif args[0] == "~" then
        user = query_me("personal_space_id")
        space_ids << user.personal_space_id
      elsif args[0] =~ /^~[0-9]+$/ then
        user = query_user(args[0].sub('~',''), "personal_space_id")
        space_ids << user.personal_space_id
      elsif args[0] =~ /^~.+@.+$/ then
        search_results = search_users( { :email=>args[0].sub('~','') },"personal_space_id" )
        space_ids += search_results.map { |r| r.personal_space_id }
      elsif args[0] =~ /^~.+$/ then
        first_name, last_name = args[0].sub('~','').split(' ')
        search_results = search_users( { :first_name=>first_name, :last_name=>last_name },"personal_space_id" )
        space_ids += search_results.map { |r| r.personal_space_id }
      else
        search_results = search_spaces(args[0],"id")
        space_ids += search_results.map { |r| r.id }

        # The built in Shared space is only availabe by
        # searching for Home. https://github.com/looker/helltool/issues/34994
        if args[0] == 'Shared' then
          search_results = search_spaces('Home',"id,is_shared_root")
          space_ids += search_results.select { |r| r.is_shared_root }.map { |r| r.id }
        end
      end if args && args.length > 0 && !args[0].nil?

      return space_ids
    end

    def all_spaces(fields=nil)
      data = nil
      begin
        req = {}
        req[:fields] = fields if fields 
        data = @sdk.all_spaces(req)
      rescue LookerSDK::Error => e
        say_error "Error querying all_spaces(#{JSON.pretty_generate(req)})"
        say_error e.message
        raise
      end
      data
    end

    def query_look(look_id)
      data = nil
      begin
        data = @sdk.look(look_id)
      rescue LookerSDK::Error => e
          say_error "Error querying look(#{look_id})"
          say_error e.message
          raise
      end
      data
    end

    def delete_look(look_id)
      data = nil
      begin
        data = @sdk.delete_look(look_id)
      rescue LookerSDK::Error => e
          say_error "Error deleting look(#{look_id})"
          say_error e.message
          raise
      end
      data
    end

    def search_looks(title, space_id=nil)
      data = nil
      begin
        req = { :title => title }
        req[:space_id] = space_id if space_id 
        data = @sdk.search_looks(req)
      rescue LookerSDK::Error => e
        say_error "Error  search_looks(#{JSON.pretty_generate(req)})"
          say_error e.message
          raise
      end
      data
    end

    def query_dashboard(dashboard_id)
      data = nil
      begin
        data = @sdk.dashboard(dashboard_id)
      rescue LookerSDK::Error => e
          say_error "Error querying dashboard(#{dashboard_id})"
          say_error e.message
          raise
      end
      data
    end

    def query_space_children(space_id, fields=nil)
      data = nil
      req = {}
      req[:fields] = fields if fields
      begin
        data = @sdk.space_children(space_id, req)
      rescue LookerSDK::Error => e
        say_error "Error querying space_children(#{space_id}, #{JSON.pretty_generate(req)})"
        say_error e.message
        raise
      end
      data
    end

    def create_query(query)
      begin
        data = @sdk.create_query(query)
      rescue LookerSDK::Error => e
          say_error "Error creating query"
          say_error e.message
          raise
      end
      data
    end

    def create_look(look)
      begin
        data = @sdk.create_look(look)
      rescue LookerSDK::Error => e
          say_error "Error creating look"
          say_error e.message
          raise
      end
      data
    end

    def keys_to_keep(operation)
      o = @sdk.operations[operation]
      begin
        say_error "Operation #{operation} not found"
        return []
      end unless o

      parameters = o[:info][:parameters].select { |p| p[:in] == "body" && p[:schema] }

      say_warning "Expecting exactly one body parameter with a schema for operation #{operation}" unless parameters.length == 1
      schema_ref = parameters[0][:schema][:$ref].split(/\//)
      return @sdk.swagger[schema_ref[1].to_sym][schema_ref[2].to_sym][:properties].reject { |k,v| v[:readOnly] }.keys
    end
    
    def write_file(file_name=nil,base_dir=nil,path=nil,output=$stdout)
      f = nil
      if base_dir.kind_of? Gem::Package::TarWriter then
        if path then
          @archived_paths ||= Array.new
          base_dir.mkdir(path.to_path, 0755) unless @archived_paths.include?(path.to_path)
          @archived_paths << path.to_path
        end
        fn = Pathname.new(file_name)
        fn = path + fn if path
        base_dir.add_file(fn.to_path, 0644) do |tf|
          yield tf
        end
        return
      end

      base = Pathname.new(File.expand_path(base_dir)) if base_dir
      begin
        p = Pathname.new(path) if path
        p.descend do |path_part|
          test_dir = base + Pathname.new(path_part)
          Dir.mkdir(test_dir) unless (test_dir.exist? && test_dir.directory?)
        end if p
        file = Pathname.new(file_name) if file_name
        file = p + file if p
        file = base + file if base
        f = File.open(file, "wt") if file
      end if base

      return ( f || output ) unless block_given?
      begin
        yield ( f || output )
      ensure
        f.close if f
      end

      nil
    end

    def read_file(file_name)
      f = nil
      data_hash = nil
      begin
        f = File.read(file_name)
        data_hash = JSON.parse(f,{:symbolize_names => true})
      ensure
        #f.close if f
      end
      return (data_hash || {}) unless block_given?

      yield data_hash || {}
    end
    
    # The cursor movement
    #
    # @see http://www.rubydoc.info/gems/tty-cursor
    #
    # @api public
    def cursor
      require 'tty-cursor'
      TTY::Cursor
    end

    # Open a file or text in the user's preferred editor
    #
    # @see http://www.rubydoc.info/gems/tty-editor
    #
    # @api public
    def editor
      require 'tty-editor'
      TTY::Editor
    end

    # File manipulation utility methods
    #
    # @see http://www.rubydoc.info/gems/tty-file
    #
    # @api public
    def generator
      require 'tty-file'
      TTY::File
    end

    # Terminal output paging
    #
    # @see http://www.rubydoc.info/gems/tty-pager
    #
    # @api public
    def pager(**options)
      require 'tty-pager'
      TTY::Pager.new(options)
    end

    # Terminal platform and OS properties
    #
    # @see http://www.rubydoc.info/gems/tty-pager
    #
    # @api public
    def platform
      require 'tty-platform'
      TTY::Platform.new
    end

    # The interactive prompt
    #
    # @see http://www.rubydoc.info/gems/tty-prompt
    #
    # @api public
    def prompt(**options)
      require 'tty-prompt'
      TTY::Prompt.new(options)
    end

    # Get terminal screen properties
    #
    # @see http://www.rubydoc.info/gems/tty-screen
    #
    # @api public
    def screen
      require 'tty-screen'
      TTY::Screen
    end

    # The unix which utility
    #
    # @see http://www.rubydoc.info/gems/tty-which
    #
    # @api public
    def which(*args)
      require 'tty-which'
      TTY::Which.which(*args)
    end

    # Check if executable exists
    #
    # @see http://www.rubydoc.info/gems/tty-which
    #
    # @api public
    def exec_exist?(*args)
      require 'tty-which'
      TTY::Which.exist?(*args)
    end
  end
end
