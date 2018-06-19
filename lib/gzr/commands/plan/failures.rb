# frozen_string_literal: true

require_relative '../../command'
require_relative '../../modules/plan'
require 'tty-table'

module Gzr
  module Commands
    class Plan
      class Failures < Gzr::Command
        include Gzr::Plan
        def initialize(options)
          super()
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning(@options) if @options[:debug]
          with_session do
            query = {
              :model=>"i__looker",
              :view=>"scheduled_plan",
              :fields=>[
                "scheduled_plan.id",
                "user.name",
                "scheduled_job.status",
                "scheduled_job.id",
                "scheduled_job.created_time",
                "scheduled_plan.next_run_time"
              ],
              :filters=>{
                "scheduled_job_stage.stage": "execute",
                "scheduled_job.created_time": "1 months",
                "scheduled_plan.run_once": "no"
              },
              :sorts=>[
                "scheduled_plan.id",
                "scheduled_job.created_time desc"
              ],
              :limit=>"5000"
            }
            data = run_inline_query(query)
            fields = query[:fields]
            expressions = fields.collect { |f| "send(\"#{f}\".to_sym)" }
            begin
              say_ok "No plans found in history"
              return nil
            end unless data && data.length > 0

            table_hash = Hash.new
            table_hash[:header] = fields unless @options[:plain]
            prior_plan_id = nil
            table_hash[:rows] = data.collect do |row|
              next if row[:"scheduled_plan.id"] == prior_plan_id
              prior_plan_id = row[:"scheduled_plan.id"]
              next if row[:"scheduled_job.status"] == 'success'
              expressions.collect do |e|
                eval "row.#{e}"
              end
            end.compact
            table = TTY::Table.new(table_hash)
            alignments = fields.collect do |k|
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
