# frozen_string_literal: true

require_relative '../../command'
require_relative '../../modules/plan'

module Gzr
  module Commands
    class Plan
      class Rm < Gzr::Command
        include Gzr::Plan
        def initialize(plan_id, options)
          super()
          @plan_id = plan_id
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options[:debug]
            with_session do
            delete_scheduled_plan(@plan_id)
          end
        end
      end
    end
  end
end
