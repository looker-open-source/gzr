# The MIT License (MIT)

# Copyright (c) 2023 Mike DeAngelo Google, Inc.

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

require_relative '../../../gzr'
require_relative '../../command'
require_relative '../../modules/alert'
require_relative '../../modules/user'
require_relative '../../modules/filehelper'

module Gzr
  module Commands
    class Alert
      class Import < Gzr::Command
        include Gzr::Alert
        include Gzr::User
        include Gzr::FileHelper
        def initialize(file, dashboard_element_id, options)
          super()
          @file = file
          @dashboard_element_id = dashboard_element_id
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}", output: output) if @options[:debug]
          with_session do

            @me ||= query_me("id")

            read_file(@file) do |data|
              data.select! do |k,v|
                keys_to_keep('create_alert').include? k
              end
              data[:owner_id] = @me[:id]
              data[:dashboard_element_id] = @dashboard_element_id if @dashboard_element_id
              alert = create_alert(data)
              output.puts "Imported alert #{alert[:id]}" unless @options[:plain]
              output.puts alert[:id] if @options[:plain]
            end
          end
        end
      end
    end
  end
end
