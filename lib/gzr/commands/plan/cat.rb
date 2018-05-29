# frozen_string_literal: true

require_relative '../../command'
require_relative '../../modules/plan'
require_relative '../../modules/filehelper'

module Gzr
  module Commands
    class Plan
      class Cat < Gzr::Command
        include Gzr::Plan
        include Gzr::FileHelper
        def initialize(plan_id,options)
          super()
          @plan_id = plan_id
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options[:debug]
          with_session do
            data = query_scheduled_plan(@plan_id)
            write_file(@options[:dir] ? "Plan_#{data.id}_#{data.name}.json" : nil, @options[:dir], nil, output) do |f|
              f.puts JSON.pretty_generate(data.to_attrs)
            end
          end
        end
      end
    end
  end
end
