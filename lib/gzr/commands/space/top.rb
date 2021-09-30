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
require_relative '../../modules/space'
require 'tty-table'

module Gzr
  module Commands
    class Space
      class Top < Gzr::Command
        include Gzr::Space
        def initialize(options)
          super()
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options[:debug]
          with_session do
            extra_fields = %w(is_shared_root is_users_root is_embed_shared_root is_embed_users_root)
            query_fields = (@options[:fields].split(',') + extra_fields).uniq
            spaces = all_spaces(query_fields.join(','))

            begin
              puts "No spaces found"
              return nil
            end unless spaces && spaces.length > 0

            table_hash = Hash.new
            fields = field_names(@options[:fields])
            table_hash[:header] = fields unless @options[:plain]
            expressions = fields.collect { |fn| field_expression(fn) }
            rows = []
            spaces.each do |h|
              if ( h.is_shared_root || h.is_users_root || h.is_embed_shared_root || h.is_embed_users_root) then
                rows << expressions.collect do |e|
                  eval "h.#{e}"
                end
              end
            end
            table_hash[:rows] = rows
            table = TTY::Table.new(table_hash)
            begin
              if @options[:csv] then
                output.puts render_csv(table)
              else
                output.puts table.render(if @options[:plain] then :basic else :ascii end, alignments: [:right], width: @options[:width] || TTY::Screen.width)
              end
            end if table
          end
        end
      end
    end
  end
end
