# frozen_string_literal: true

require 'forwardable'

require 'tty-reader'
require 'netrc'

#require 'rubygems'
#require 'rubygems/package'
require 'bundler/setup'
require 'looker-sdk'

require_relative 'modules/session'

module Lkr
  class Command
    extend Forwardable
    include Lkr::Session

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
    
    
  end
end
