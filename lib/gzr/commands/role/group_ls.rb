# frozen_string_literal: true

require_relative '../../command'
require_relative '../../modules/role'
require 'tty-table'

module Gzr
  module Commands
    class Role
      class GroupLs < Gzr::Command
        include Gzr::Role
        def initialize(role_id,options)
          super()
          @role_id = role_id
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning(@options) if @options[:debug]
          with_session do
            data = query_role_groups(@role_id,@options[:fields])
            begin
              say_ok "No role groups found"
              return nil
            end unless data && data.length > 0

            table_hash = Hash.new
            fields = field_names(@options[:fields])
            table_hash[:header] = fields unless @options[:plain]
            expressions = fields.collect { |fn| field_expression(fn) }
            table_hash[:rows] = data.map do |row|
              expressions.collect do |e|
                v = eval "row.#{e}"
                next (v.join "\n") if v.kind_of? Array
                v
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
                output.puts table.render(if @options[:plain] then :basic else :ascii end, multiline: true, alignments: alignments)
              end
            end if table
          end
        end
      end
    end
  end
end
