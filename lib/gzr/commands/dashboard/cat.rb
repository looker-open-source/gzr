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
            data = cat_dashboard(@dashboard_id)

            replacements = {}
            if @options[:transform]

              max_row = 0
              data[:dashboard_layouts][0][:dashboard_layout_components].each_index do |i|
                component = data[:dashboard_layouts][0][:dashboard_layout_components][i]
                if component[:row] + component[:height] > max_row
                  max_row = component[:row] + component[:height] + 4
                end
              end

              read_file(@options[:transform]) do |transform|
                i = 0
                transform[:dashboard_elements].collect! do |e|
                  i += 1
                  # there is no significance to 9900, we just need to prevent ID collisions
                  e['id'] = 9900 + i
                  data[:dashboard_elements] << e

                  # when inserting an element into the top row, shift the other elements down according to the height of the inserted element
                  if e[:position] === 'top'
                    data[:dashboard_layouts][0][:dashboard_layout_components].each_index do |i|
                      component = data[:dashboard_layouts][0][:dashboard_layout_components][i]
                      component[:row] = component[:row] + e[:height]
                    end
                    row = '0'
                  elsif e[:position] === 'bottom'
                    row = max_row.to_s
                  end

                  column = '0'
                  width = e[:width].to_s
                  height = e[:height].to_s
                  data[:dashboard_layouts][0][:dashboard_layout_components] << JSON.parse('{"id":' + e['id'].to_s + ',"dashboard_layout_id":1,"dashboard_element_id":' + e['id'].to_s + ''',"row":' + row + ',"column":' + column + ',"width":' + width + ',"height":' + height + ',"deleted":false,"element_title_hidden":false,"vis_type":"' + e[:type].to_s + '","can":{"index":true,"show":true,"create":true,"update":true,"destroy":true}}')
                end

                transform[:replacements].collect! do |e|
                  replacements[e.keys.first.to_s] = e[e.keys[0]]
                end

              end
            end

            outputJSON = JSON.pretty_generate(data)

            replacements.each do |k,v|
              say_warning("Replaced #{k} with #{v}") if @options[:debug]
              outputJSON.gsub! k,v
            end

            file_name = if @options[:dir]
                          @options[:simple_filename] ? "Dashboard_#{data[:id]}.json" : "Dashboard_#{data[:id]}_#{data[:title]}.json"
                        else
                          nil
                        end
            write_file(file_name, @options[:dir], nil, output) do |f|
              f.puts outputJSON
            end
          end
        end
      end
    end
  end
end
