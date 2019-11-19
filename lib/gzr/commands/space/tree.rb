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
require 'tty-tree'

# The tty-tree tool is built on the idea of handling directories, so it does
# parsing based on slashs (or backslashs on Windows). If those characters are
# in object names, tty-tree pulls them out.
# This monkey patch disables that.

module TTY
  class Tree
    class Node
      def initialize(path, parent, prefix, level)
        if path.is_a? String
          # strip null bytes from the string to avoid throwing errors
          path = path.delete("\0")
        end

        @path = path
        @name   = path
        @parent = parent
        @prefix = prefix
        @level  = level
      end
    end
  end
end

module Gzr
  module Commands
    class Space
      class Tree < Gzr::Command
        include Gzr::Space
        def initialize(filter_spec, options)
          super()
          @filter_spec = filter_spec
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options[:debug]
          with_session do
            space_ids = process_args([@filter_spec])

            tree_data = Hash.new
            
            space_ids.each do |space_id| 
              s = query_space(space_id, "id,name,parent_id,looks(id,title),dashboards(id,title)")
              space_name = s.name
              space_name = "nil (#{s.id})" unless space_name 
              space_name = "\"#{space_name}\"" if ((space_name != space_name.strip) || (space_name.length == 0))
              space_name += " (#{space_id})" unless space_ids.length == 1
              tree_data[space_name] =
                [ recurse_spaces(s.id) ] +
                s.looks.map { |l| "(l) #{l.title}" } +
                  s.dashboards.map { |d| "(d) #{d.title}" }
            end
            tree = TTY::Tree.new(tree_data)
            output.puts tree.render
          end
        end

        def recurse_spaces(space_id)
          data = query_space_children(space_id, "id,name,parent_id,looks(id,title),dashboards(id,title)")
          tree_branch = Hash.new
          data.each do |s|
            space_name = s.name
            space_name = "nil (#{s.id})" unless space_name 
            space_name = "\"#{space_name}\"" if ((space_name != space_name.strip) || (space_name.length == 0))
            tree_branch[space_name] =
              [ recurse_spaces(s.id) ] +
              s.looks.map { |l| "(l) #{l.title}" } +
              s.dashboards.map { |d| "(d) #{d.title}" }
          end
          tree_branch
        end
      end
    end
  end
end
