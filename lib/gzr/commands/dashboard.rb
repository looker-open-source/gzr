# frozen_string_literal: true

require_relative 'subcommandbase'

module Gzr
  module Commands
    class Dashboard < SubCommandBase

      namespace :dashboard

      desc 'cat DASHBOARD_ID', 'Output the JSON representation of a dashboard to the screen or a file'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :dir,  type: :string,
                           desc: 'Directory to store output file'
      def cat(dashboard_id)
        if options[:help]
          invoke :help, ['cat']
        else
          require_relative 'dashboard/cat'
          Gzr::Commands::Dashboard::Cat.new(dashboard_id, options).execute
        end
      end

      desc 'import FILE DEST_SPACE_ID', 'Import a dashboard from a file'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def import(file,dest_space_id)
        if options[:help]
          invoke :help, ['import']
        else
          require_relative 'dashboard/import'
          Gzr::Commands::Dashboard::Import.new(file, dest_space_id, options).execute
        end
      end

      desc 'rm DASHBOARD_ID', 'Remove or delete the given dashboard'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def rm(id)
        if options[:help]
          invoke :help, ['rm']
        else
          require_relative 'dashboard/rm'
          Gzr::Commands::Dashboard::Rm.new(id, options).execute
        end
      end
    end
  end
end
