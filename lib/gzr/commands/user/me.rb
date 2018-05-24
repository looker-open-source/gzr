# frozen_string_literal: true

require_relative '../../command'
require_relative '../../modules/user'
require 'tty-table'

module Gzr
  module Commands
    class User
      class Me < Gzr::Command
        include Gzr::User

        def initialize(options)
          super()
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning(@options) if @options[:debug]
          with_session do
            data = query_me(@options[:fields])
            table_hash = Hash.new
            fields = field_names(@options[:fields])
            table_hash[:header] = fields unless @options[:plain]
            expressions = fields.collect { |fn| field_expression(fn) }
            table_hash[:rows] = [expressions.collect do |e|
              eval "data.#{e}"
            end]
            table = TTY::Table.new(table_hash) if data
            alignments = fields.collect do |k|
              (k =~ /id$/) ? :right : :left
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
