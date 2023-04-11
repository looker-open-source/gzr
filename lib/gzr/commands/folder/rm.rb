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
require_relative '../../modules/folder'

module Gzr
  module Commands
    class Folder
      class Rm < Gzr::Command
        include Gzr::Folder
        def initialize(folder,options)
          super()
          @folder = folder
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          with_session do
            folder = query_folder(@folder)

            begin
              puts "Folder #{@folder} not found"
              return nil
            end unless folder
            children = query_folder_children(@folder)
            unless (folder.looks.length == 0 && folder.dashboards.length == 0 && children.length == 0) || @options[:force] then
              raise Gzr::CLI::Error, "Folder '#{folder.name}' is not empty. Folder cannot be deleted unless --force is specified"
            end
            delete_folder(@folder)
          end
        end
      end
    end
  end
end
