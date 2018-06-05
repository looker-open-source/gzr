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
                output.puts table.render(if @options[:plain] then :basic else :ascii end, alignments: alignments)
              end
            end if table
          end
        end
      end
    end
  end
end
