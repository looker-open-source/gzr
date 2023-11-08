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
require 'tty-table'

module Gzr
  module Commands
    class Project
      class Branch < Gzr::Command
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

            say_warning "querying git_branch(#{@project_id})" if @options[:debug]
            data = [git_branch(@project_id)]
            begin
              say_ok "No active branch found"
              return nil
            end unless data && data.length > 0

            if @options[:all]
              say_warning "querying all_git_branches(#{@project_id})" if @options[:debug]
              data += all_git_branches(@project_id).select{ |e| e[:name] != data[0][:name] }
            end
            begin
              say_ok "No branches found"
              return nil
            end unless data && data.length > 0

            table_hash = Hash.new
            fields = field_names(@options[:fields])
            table_hash[:header] = fields unless @options[:plain]
            table_hash[:rows] = data.map do |row|
              field_expressions_eval(fields,row)
            end
            table = TTY::Table.new(table_hash)
            alignments = fields.collect do |k|
              (k =~ /id$/) ? :right : :left
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
