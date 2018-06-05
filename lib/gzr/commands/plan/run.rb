# frozen_string_literal: true

require_relative '../../command'
require_relative '../../modules/plan'

module Gzr
  module Commands
    class Plan
      class Run < Gzr::Command
        include Gzr::Plan
        def initialize(plan_id,options)
          super()
          @plan_id = plan_id
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options[:debug]
          with_session do
              output.puts "Executed plan #{@plan_id}" unless @options[:plain] 
          end
        end
      end
    end
  end
end
