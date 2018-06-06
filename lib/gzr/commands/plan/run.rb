# frozen_string_literal: true

require_relative '../../command'
require_relative '../../modules/plan'

module Gzr
  module Commands
    class Plan
      class RunIt < Gzr::Command
        include Gzr::Plan
        def initialize(plan_id,options)
          super()
          @plan_id = plan_id
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options[:debug]
          with_session do
            plan = query_scheduled_plan(@plan_id)&.to_attrs
            # The api call scheduled_plan_run_once is an odd duck. It accepts
            # the output of any of the calls to retrieve a scheduled plan
            # even though many of the attributes passed are marked read-only.
            # Furthermore, if there is a "secret" - like the password for 
            # sftp or s3 - it will match the plan body up with the plan
            # as known in the server and if they are identical apart from
            # the secret, the api will effectively include to secret in order
            # execute the plan.
            run_scheduled_plan(plan)
            output.puts "Executed plan #{@plan_id}" unless @options[:plain] 
          end
        end
      end
    end
  end
end
