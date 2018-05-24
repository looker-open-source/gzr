# frozen_string_literal: true

require_relative '../../command'
require_relative '../../modules/dashboard'

module Gzr
  module Commands
    class Dashboard
      class Rm < Gzr::Command
        include Gzr::Dashboard
        def initialize(dashboard,options)
          super()
          @dashboard = dashboard
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options[:debug]
          with_session do
            delete_dashboard(@dashboard)
          end
        end
      end
    end
  end
end
