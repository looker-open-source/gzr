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
                           desc: 'Directory to get output file'
      def cat(dashboard_id=nil)
        if options[:help]
          invoke :help, ['cat']
        else
          require_relative 'dashboard/cat'
          Lkr::Commands::Dashboard::Cat.new(options).execute(dashboard_id)
        end
      end
    end
  end
end
