# frozen_string_literal: true

require_relative 'subcommandbase'

module Gzr
  module Commands
    class Connection < SubCommandBase

      namespace :connection

      desc 'dialects', 'List all available dialects'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :fields, type: :string, default: 'name,label',
                           desc: 'Fields to display'
      method_option :plain, type: :boolean, default: false,
                           desc: 'print without any extra formatting'
      method_option :csv, type: :boolean, default: false,
                           desc: 'output in csv format per RFC4180'
      def dialects(*)
        if options[:help]
          invoke :help, ['dialects']
        else
          require_relative 'connection/dialects'
          Gzr::Commands::Connection::Dialects.new(options).execute
        end
      end

      desc 'ls', 'List all available connections'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :fields, type: :string, default: 'name,dialect(name),host,port,database,schema',
                           desc: 'Fields to display'
      method_option :plain, type: :boolean, default: false,
                           desc: 'print without any extra formatting'
      method_option :csv, type: :boolean, default: false,
                           desc: 'output in csv format per RFC4180'
      def ls(*)
        if options[:help]
          invoke :help, ['ls']
        else
          require_relative 'connection/ls'
          Gzr::Commands::Connection::Ls.new(options).execute
        end
      end
    end
  end
end
