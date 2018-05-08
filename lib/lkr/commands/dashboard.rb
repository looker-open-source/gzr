# frozen_string_literal: true

require 'thor'

module Lkr
  module Commands
    class Dashboard < Thor

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
          Lkr::Commands::Dashboard::Cat.new(dashboard_id, options).execute
        end
      end
    end
  end
end
