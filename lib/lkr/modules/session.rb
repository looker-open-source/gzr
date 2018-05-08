# frozen_string_literal: true

require 'pastel'

module Lkr
  module Session

    def pastel
      @pastel ||= Pastel.new
    end

    def say_ok(data)
      puts pastel.green data
    end

    def say_warning(data)
      puts pastel.yellow data
    end

    def say_error(data)
      puts pastel.red data
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

  end
end