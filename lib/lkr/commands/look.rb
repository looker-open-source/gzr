# frozen_string_literal: true

require 'thor'

module Lkr
  module Commands
    class Look < Thor

      namespace :look

      desc 'cat LOOK_ID', 'Output the JSON representation of a look to the screen or a file'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :dir,  type: :string,
                           desc: 'Directory to get output file'
      def cat(look_id=nil)
        if options[:help]
          invoke :help, ['cat']
        else
          require_relative 'look/cat'
          Lkr::Commands::Look::Cat.new(options).execute(look_id)
        end
      end
    end
  end
end
