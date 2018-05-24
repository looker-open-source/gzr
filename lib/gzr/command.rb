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

    private

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

    def field_expression(name)
      parts = name.split(/\./)
      parts.join('&.')
    end
  end
end
