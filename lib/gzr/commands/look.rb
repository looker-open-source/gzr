# frozen_string_literal: true

require_relative 'subcommandbase'

module Gzr
  module Commands
    class Look < SubCommandBase

      namespace :look

      desc 'rm LOOK_ID', 'Delete look given by LOOK_ID'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def rm(look_id)
        if options[:help]
          invoke :help, ['rm']
        else
          require_relative 'look/rm'
          Gzr::Commands::Look::Rm.new(look_id, options).execute
        end
      end

      desc 'import FILE DEST_SPACE_ID', 'Import a look from a file'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def import(file,dest_space_id)
        if options[:help]
          invoke :help, ['import']
        else
          require_relative 'look/import'
          Gzr::Commands::Look::Import.new(file, dest_space_id, options).execute
        end
      end

      desc 'cat LOOK_ID', 'Output the JSON representation of a look to the screen or a file'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :dir,  type: :string,
                           desc: 'Directory to store output file'
      def cat(look_id)
        if options[:help]
          invoke :help, ['cat']
        else
          require_relative 'look/cat'
          Gzr::Commands::Look::Cat.new(look_id, options).execute
        end
      end
    end
  end
end
