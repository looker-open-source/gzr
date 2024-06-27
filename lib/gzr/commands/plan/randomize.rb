# The MIT License (MIT)

# Copyright (c) 2024 Mike DeAngelo Google, Inc.

# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# frozen_string_literal: true

require_relative '../../command'
require_relative '../../modules/plan'
require_relative '../../modules/user'
require_relative '../../modules/cron'

module Gzr
  module Commands
    class Plan
      class Randomize < Gzr::Command
        include Gzr::Plan
        include Gzr::User
        include Gzr::Cron
        def initialize(plan_id,options)
          super()
          @plan_id = plan_id
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options[:debug]

          window = @options[:window]
          if window < 1 or window > 60
            say_error("window must be between 1 and 60")
            raise Gzr::CLI::Error.new()
          end

          with_session do
            @me ||= query_me("id")

            if @plan_id
              plan = query_scheduled_plan(@plan_id)
              if plan
                randomize_plan(plan,window)
              else
                say_warning("Plan #{@plan_id} not found")
              end
            else
              plans = query_all_scheduled_plans( @options[:all]?'all':@me[:id] )
              plans.each do |plan|
                randomize_plan(plan,window)
              end
            end
          end
        end

        def randomize_plan(plan,window=60)
          crontab = plan[:crontab]
          if crontab == ""
            say_warning("skipping plan #{plan[:id]} with no crontab")
            return
          end
          crontab = randomize_cron(crontab, window)
          begin
            update_scheduled_plan(plan[:id], { crontab: crontab })
          rescue LookerSDK::UnprocessableEntity => e
            say_warning("Skipping invalid entry")
          end
        end
      end
    end
  end
end
