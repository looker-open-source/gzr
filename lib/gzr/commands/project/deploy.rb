
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

require_relative '../../command'
require_relative '../../modules/project'

module Gzr
  module Commands
    class Project
      class Deploy < Gzr::Command
        include Gzr::Project
        def initialize(project_id,options)
          super()
          @project_id = project_id
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning(@options) if @options[:debug]
          with_session do
            if get_auth()[:workspace_id] == 'production'
              say_warning %Q(
This command only works in dev mode. Use persistent sessions and
change to dev mode before running this command.

$ gzr session login --host looker.example.com
$ gzr session update dev --token_file --host looker.example.com
$ # run the command requiring dev mode here with the --token_file switch
$ gzr session logout --token_file --host looker.example.com
              )
              return
            end
            data = deploy_to_production(@project_id)
            if data.nil?
              say_warning "Project #{@project_id} not found"
              return
            end
           output.puts data
          end
        end
      end
    end
  end
end
