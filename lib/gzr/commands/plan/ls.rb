# The MIT License (MIT)

# Copyright (c) 2018 Mike DeAngelo Looker Data Sciences, Inc.

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
require 'tty-table'

module Gzr
  module Commands
    class Plan
      class Ls < Gzr::Command
        include Gzr::Plan
        def initialize(options)
          super()
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning(@options) if @options[:debug]
          with_session do
            fields = nil
            expressions = nil
            if @options[:disabled] then
              query = {
                :model=>"i__looker",
                :view=>"scheduled_plan",
                :fields=>[
                  "scheduled_plan.id",
                  "scheduled_plan.enabled",
                  "scheduled_plan.name",
                  "user.id",
                  "user.name",
                  "scheduled_plan.look_id",
                  "scheduled_plan.dashboard_id",
                  "scheduled_plan.lookml_dashboard_id"
                ],
                :filters=>{
                  "scheduled_plan.enabled"=>false
                },
                :sorts=>[
                  "scheduled_plan.id asc 0"
                ],
                :limit=>"500"
              }
              data = run_inline_query(query)
              fields = query[:fields]
              expressions = fields.collect { |f| "send(\"#{f}\".to_sym)" }
            else
              data = query_all_scheduled_plans("all",@options[:fields])
              fields = field_names(@options[:fields])
              expressions = fields.collect { |fn| field_expression(fn) }
            end
            begin
              say_ok "No plans found"
              return nil
            end unless data && data.length > 0

            table_hash = Hash.new
            table_hash[:header] = fields unless @options[:plain]
            table_hash[:rows] = data.map do |row|
              expressions.collect do |e|
                eval "row.#{e}"
              end
            end
            table = TTY::Table.new(table_hash)
            alignments = fields.collect do |k|
              next :left if k == "external_group_id"
              (k =~ /(id|count)$/) ? :right : :left
            end
            begin
              if @options[:csv] then
                output.puts render_csv(table)
              else
                output.puts table.render(if @options[:plain] then :basic else :ascii end, alignments: alignments, width: @options[:width] || TTY::Screen.width)
              end
            end if table
          end
        end
      end
    end
  end
end
