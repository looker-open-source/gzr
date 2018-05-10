# frozen_string_literal: true

require 'thor'

module Lkr
  module Commands
    class Connection < Thor

      namespace :connection

      desc 'dialects', 'List all available dialects'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :fields, type: :string, default: 'name,label',
                           desc: 'Fields to display'
      method_option :plain, type: :boolean, default: false,
                           desc: 'print without any extra formatting'
      def dialects(*)
        if options[:help]
          invoke :help, ['dialects']
        else
          require_relative 'connection/dialects'
          Lkr::Commands::Connection::Dialects.new(options).execute
        end
      end

      desc 'ls', 'List all available connections'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :fields, type: :string, default: 'name,dialect(name),host,port,database,schema',
                           desc: 'Fields to display'
      method_option :plain, type: :boolean, default: false,
                           desc: 'print without any extra formatting'
      def ls(*)
        if options[:help]
          invoke :help, ['ls']
        else
          require_relative 'connection/ls'
          Lkr::Commands::Connection::Ls.new(options).execute
        end
      end

      def self.banner(command, namespace = nil, subcommand = false)
        "#{basename} #{subcommand_prefix} #{command.usage}"
      end

      def self.subcommand_prefix
        self.name.gsub(%r{.*::}, '').gsub(%r{^[A-Z]}) { |match| match[0].downcase }.gsub(%r{[A-Z]}) { |match| "-#{match[0].downcase}" }
      end
    end
  end
end
