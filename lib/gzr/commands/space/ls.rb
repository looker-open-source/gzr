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
      class Ls < Gzr::Command
        include Gzr::Space
        def initialize(filter_spec, options)
          super()
          @filter_spec = filter_spec
          @options = options
        end

        def flatten_data(raw_array)
          rows = raw_array.map do |entry|
            entry.select do |k,v|
              !(v.kind_of?(Array) || v.kind_of?(Hash))
            end
          end
          raw_array.map do |entry|
            entry.select do |k,v|
              v.kind_of? Array
            end.each do |section,section_value|
              section_value.each do |section_entry|
                h = {}
                section_entry.each_pair do |k,v|
                  h[:"#{section}.#{k}"] = v
                end
                rows.push(h)
              end
            end
          end
          rows
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options[:debug]
          with_session do
            space_ids = process_args([@filter_spec])
            begin
              puts "No spaces match #{@filter_spec}"
              return nil
            end unless space_ids && space_ids.length > 0

            @options[:fields] = 'dashboards(id,title)' if @filter_spec == 'lookml'
            f = @options[:fields]

            data = space_ids.map do |space_id|
              query_space(space_id, f).to_attrs
            end.compact
            space_ids.each do |space_id|
              query_space_children(space_id, 'id,name,parent_id').map {|child| child.to_attrs}.each do |child|
                data.push child
              end
            end


            begin
              puts "No data returned for spaces #{space_ids.inspect}"
              return nil
            end unless data && data.length > 0

            table_hash = Hash.new
            fields = field_names(@options[:fields])
            table_hash[:header] = fields unless @options[:plain]
            table_hash[:rows] = flatten_data(data).map do |row|
              fields.collect do |e|
                row.fetch(e.to_sym,nil)
              end
            end
            table = TTY::Table.new(table_hash)
            alignments = fields.collect do |k|
              (k =~ /id\)*$/) ? :right : :left
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
