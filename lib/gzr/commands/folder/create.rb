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
      class Create < Gzr::Command
        include Gzr::Folder
        def initialize(name,parent_folder, options)
          super()
          @name = name
          @parent_folder = parent_folder
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          folder = nil
          with_session do
            folder = create_folder(@name, @parent_folder)
            output.puts "Created folder #{folder.id}" unless @options[:plain] 
            output.puts folder.id if @options[:plain] 
          end
        end
      end
    end
  end
end
