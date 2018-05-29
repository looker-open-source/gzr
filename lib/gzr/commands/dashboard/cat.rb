# frozen_string_literal: true

require 'json'
require_relative '../../command'
require_relative '../../modules/dashboard'
require_relative '../../modules/plan'
require_relative '../../modules/filehelper'

module Gzr
  module Commands
    class Dashboard
      class Cat < Gzr::Command
        include Gzr::Dashboard
        include Gzr::FileHelper
        include Gzr::Plan
        def initialize(dashboard_id,options)
          super()
          @dashboard_id = dashboard_id
          @options = options
        end

        def execute(*args, input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options[:debug]
          with_session do
            data = query_dashboard(@dashboard_id)
            data[:scheduled_plans] = query_scheduled_plans_for_dashboard(@dashboard_id,"all") if @options[:plans]
            write_file(@options[:dir] ? "Dashboard_#{data.id}_#{data.title}.json" : nil, @options[:dir], nil, output) do |f|
              f.puts JSON.pretty_generate(data.to_attrs)
            end
          end
        end
      end
    end
  end
end
