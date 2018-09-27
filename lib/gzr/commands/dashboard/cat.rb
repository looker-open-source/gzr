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
          with_session("3.1") do
            data = query_dashboard(@dashboard_id)
            data.to_attrs()[:dashboard_elements].each_index do |i|
              element = data[:dashboard_elements][i]
              if element[:merge_result_id]
                merge_result = merge_query(element[:merge_result_id])
                merge_result[:source_queries].each_index do |j|
                  source_query = merge_result[:source_queries][j]
                  merge_result[:source_queries][j][:query] = query(source_query[:query_id])
                end
                data[:dashboard_elements][i][:merge_result] = merge_result
              end
            end
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
