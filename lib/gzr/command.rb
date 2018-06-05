# frozen_string_literal: true

require 'forwardable'
require 'tty-reader'
require 'netrc'
require 'looker-sdk'

require_relative 'modules/session'

module Gzr
  class Command
    extend Forwardable
    include Gzr::Session

    def initialize
      @sdk = nil
      @access_token_stack = Array.new
      @options = Hash.new
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

    def create_query(query)
      begin
        data = @sdk.create_query(query)
      rescue LookerSDK::Error => e
        say_error "Error creating query(#{JSON.pretty_generate(query)})"
        say_error e.message
        raise
      end
      data
    end

    def run_inline_query(query)
      begin
        data = @sdk.run_inline_query("json",query)
      rescue LookerSDK::Error => e
        say_error "Error running inline_query(#{JSON.pretty_generate(query)})"
        say_error e.message
        raise
      end
      data
    end


    ##
    # This method accepts the name of an sdk operation, then finds the parameter for that
    # operation in the data structures from the swagger.json file. The parameter is a
    # json object. Some of the attributes of the json object are read-only, and some
    # are read-write. A few are write-only. The list of read-write and write-only attribute
    # names are returned as an array. That array can be used to take the json document that
    # describes an object and strip out the read-only values, creating a document that can
    # be used to create or update an object.
    #
    # The pattern typically looks like this...
    #
    #   new_obj_hash = existing_obj_hash.select do |k,v|
    #     keys_to_keep('create_new_obj').include? k
    #   end
    
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
    
    ##
    # The tty-table gem is normally used to output tabular data. This method accepts a Table
    # object as used by the tty-table gem, and generates CSV output. It returns a string
    # with crlf encoding
    
    def render_csv(t)
      io = StringIO.new
      io.puts (
        t.header.collect do |v|
          v ? "\"#{v.to_s.gsub(/"/, '""')}\"" : ""
        end.join(',')
      ) unless @options[:plain]
      t.each do |row|
        next if row === t.header
        io.puts (
          row.collect do |v|
            v ? "\"#{v.to_s.gsub(/"/, '""')}\"" : ""
          end.join(',')
        )
      end
      io.rewind
      io.gets(nil).encode(crlf_newline: true)
    end

    ##
    # This method accepts a string containing a list of fields. The fields can be nested
    # in a format like...
    #
    # 'a,b,c(d,e(f,g)),h'
    #
    # representing a structure like
    #
    # {
    #   a: "val",
    #   b: "val",
    #   c: {
    #     d: "val",
    #     e: {
    #       f: "val",
    #       g: "val"
    #     }
    #   },
    #   h: "val"
    # }
    #
    # That string will get parsed and yield an array like
    # [ a, b, c.d, c.e.f, c.e.g, h ]
    #

    def field_names(opt_fields)
      fields = []
      token_stack = []
      last_token = false
      tokens = opt_fields.split /(\(|,|\))/
      tokens << nil
      tokens.each do |t|
        if t.nil? then
          fields << (token_stack + [last_token]).join('.') if last_token
        elsif t.empty? then
          next
        elsif t == ',' then
          fields << (token_stack + [last_token]).join('.') if last_token
        elsif t == '(' then
          token_stack.push(last_token)
        elsif t == ')' then
          fields << (token_stack + [last_token]).join('.') if last_token
          token_stack.pop
          last_token = false
        else
          last_token = t
        end
      end
      fields
    end

    ##
    # This method will accept a field name in a format like 'c.e.g'
    # and convert it into 'c&.e&.g', which can be evaluated to get
    # the value of g, or nil if any intermediate value is nil.

    def field_expression(name)
      parts = name.split(/\./)
      parts.join('&.')
    end

    ##
    # This method will accept two arrays, a and b, and create a third array
    # like [ [a[0],b[0]], [a[1],b[1]], [a[2],b[2]], ...].
    # If either array is longer than the other, additional pairs 
    # will be generated with the shorter array padded out with nil values.
    #
    # Any additional args will be added to each inner array.

    def pairs(a, b, *args)
      pair_array = Array.new([a.count,b.count].max) do |i|
        pair = [a.fetch(i,nil),b.fetch(i,nil)]
        pair + args if args
        pair
      end

      return pair_array unless block_given?

      pair_array.collect { |e| yield(e) }
    end
  end
end
