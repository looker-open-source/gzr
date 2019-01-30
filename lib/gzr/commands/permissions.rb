# frozen_string_literal: true

require 'thor'

module Gzr
  module Commands
    class Permissions < Thor

      namespace :permissions

      desc 'ls', 'List all available permissions'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :plain, type: :boolean, default: false,
                           desc: 'print without any extra formatting'
      method_option :csv, type: :boolean, default: false,
                           desc: 'output in csv format per RFC4180'
      def ls(*)
        if options[:help]
          invoke :help, ['ls']
        else
          require_relative 'permissions/ls'
          Gzr::Commands::Permissions::Ls.new(options).execute
        end
      end
    end
  end
end
