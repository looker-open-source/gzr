# frozen_string_literal: true

require 'thor'

module Lkr
  module Commands
    class Dashboard < Thor

      namespace :dashboard

      desc 'cat', 'Command description...'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def cat(*)
        if options[:help]
          invoke :help, ['cat']
        else
          require_relative 'dashboard/cat'
          Lkr::Commands::Dashboard::Cat.new(options).execute
        end
      end
    end
  end
end
