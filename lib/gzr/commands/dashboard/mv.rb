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

require_relative '../../../gzr'
require_relative '../../command'
require_relative '../../modules/dashboard'

module Gzr
  module Commands
    class Dashboard
      class Mv < Gzr::Command
        include Gzr::Dashboard
        def initialize(dashboard_id, target_folder_id, options)
          super()
          @dashboard_id = dashboard_id
          @target_folder_id = target_folder_id
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}", output: output) if @options[:debug]
          with_session do

            dash = query_dashboard(@dashboard_id)
            raise Gzr::CLI::Error, "Dashboard with id #{@dashboard_id} does not exist" unless dash

            matching_title = search_dashboards_by_title(dash[:title],@target_folder_id)
            if matching_title.empty? || matching_title.first[:deleted]
              matching_title = false
            end
            
            if matching_title
              raise Gzr::CLI::Error, "Dashboard #{dash[:title]} already exists in folder #{@target_folder_id}\nUse --force if you want to overwrite it" unless @options[:force]
              say_ok "Deleting existing dashboard #{matching_title.first[:id]} #{matching_title.first[:title]} in folder #{@target_folder_id}", output: output
              update_dashboard(matching_title.first[:id],{:deleted=>true})
            end
            update_dashboard(dash[:id],{:folder_id=>@target_folder_id})
            output.puts "Moved dashboard #{dash[:id]} to folder #{@target_folder_id}" unless @options[:plain] 
          end
        end
      end
    end
  end
end
