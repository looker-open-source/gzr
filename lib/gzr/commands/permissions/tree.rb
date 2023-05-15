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
require_relative '../../modules/permissions'
require 'tty-tree'

require_relative '../../command'

module Gzr
  module Commands
    class Permissions
      class Tree < Gzr::Command
        include Gzr::Permissions
        def initialize(options)
          super()
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning(@options) if @options[:debug]
          with_session do
            data = query_all_permissions()
            begin
              say_ok "No permissions found"
              return nil
            end unless data && data.length > 0

            tree_data = Hash.new

            data.sort! { |a,b| a[:permission] <=> b[:permission] }
            data.select {|e| e[:parent] == nil}.each do |e|
              tree_data[e[:permission]] = [recurse_permissions(e[:permission], data)]
            end

            tree = TTY::Tree.new(tree_data)
            output.puts tree.render
          end
        end

        def recurse_permissions(permission, data)
          tree_branch = Hash.new
          data.select { |e| e[:parent] == permission }.each do |e|
            tree_branch[e[:permission]] = [recurse_permissions(e[:permission], data)]
          end
          tree_branch
        end
      end
    end
  end
end
