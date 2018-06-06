# frozen_string_literal: true

require_relative '../../command'
require_relative '../../modules/plan'

module Gzr
  module Commands
    class Plan
      class Enable < Gzr::Command
        include Gzr::Plan
        def initialize(plan_id,options)
          super()
          @plan_id = plan_id
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options[:debug]
          with_session do
            plan = update_scheduled_plan(@plan_id, { :enabled=>true })
            output.puts "Enabled plan #{plan.id}" unless @options[:plain] 
            output.puts plan.id if @options[:plain] 
          end
        end
      end
    end
  end
end
