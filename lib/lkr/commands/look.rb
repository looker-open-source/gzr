# frozen_string_literal: true

require 'thor'

module Lkr
  module Commands
    class Look < Thor

      namespace :look

      desc 'cat', 'Command description...'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def cat(*)
        if options[:help]
          invoke :help, ['cat']
        else
          require_relative 'look/cat'
          Lkr::Commands::Look::Cat.new(options).execute
        end
      end
    end
  end
end
