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

require 'thor'

module Gzr
  module Commands
    class Project < Thor

      namespace :project

      desc 'ls', 'List all projects'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :fields, type: :string, default: 'id,name,git_production_branch_name',
                           desc: 'Fields to display'
      method_option :plain, type: :boolean, default: false,
                           desc: 'print without any extra formatting'
      method_option :csv, type: :boolean, default: false,
                           desc: 'output in csv format per RFC4180'

      def ls(*)
        if options[:help]
          invoke :help, ['ls']
        else
          require_relative 'project/ls'
          Gzr::Commands::Project::Ls.new(options).execute
        end
      end

      desc 'cat PROJECT_ID', 'Output json information about a project to screen or file'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :dir,  type: :string,
                           desc: 'Directory to store output file'
      method_option :trim, type: :boolean,
                           desc: 'Trim output to minimal set of fields for later import'
      def cat(project_id)
        if options[:help]
          invoke :help, ['cat']
        else
          require_relative 'project/cat'
          Gzr::Commands::Project::Cat.new(project_id,options).execute
        end
      end

      desc 'import PROJECT_FILE', 'Import a project from a file containing json information'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def import(project_file)
        if options[:help]
          invoke :help, ['import']
        else
          require_relative 'project/import'
          Gzr::Commands::Project::Import.new(project_file,options).execute
        end
      end

      desc 'update PROJECT_ID PROJECT_FILE', 'Update the given project from a file containing json information'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def update(project_id,project_file)
        if options[:help]
          invoke :help, ['update']
        else
          require_relative 'project/update'
          Gzr::Commands::Project::Update.new(project_id,project_file,options).execute
        end
      end

    end
  end
end
