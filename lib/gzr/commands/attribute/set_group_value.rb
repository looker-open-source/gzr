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
require_relative '../../modules/group'
require_relative '../../modules/attribute'

module Gzr
  module Commands
    class Attribute
      class SetGroupValue < Gzr::Command
        include Gzr::Attribute
        include Gzr::Group
        def initialize(group,attr,value,options)
          super()
          @group = group
          @attr = attr
          @value = value
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning(@options) if @options[:debug]
          with_session("3.1") do

            group_id = @group if /^\d+$/.match @group
            group = nil
            if group_id
              group = query_group(group_id)
            else
              results = search_groups(@group)
              if results && results.length == 1
                group = results.first
              elsif results
                raise(Gzr::CLI::Error, "Pattern #{@group} matched more than one group")
              else
                raise(Gzr::CLI::Error, "Pattern #{@group} did not match any groups")
              end
            end

            attr_id = @attr if /^\d+$/.match @attr
            attr = nil
            if attr_id
              attr = query_user_attribute(attr_id)
            else
              attr = get_attribute_by_name(@attr)
            end
            raise(Gzr::CLI::Error, "Attribute #{@attr} does not exist") unless attr

            data = update_user_attribute_group_value(group.id,attr.id, @value)
            say_warning("Attribute #{attr.name} does not have a value set for group #{group.name}", output: output) unless data
            output.puts "Group attribute #{data.id} set to #{data.value}"
          end
        end
      end
    end
  end
end
