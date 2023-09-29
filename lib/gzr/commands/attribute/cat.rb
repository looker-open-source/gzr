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
require_relative '../../modules/attribute'
require_relative '../../modules/filehelper'

module Gzr
  module Commands
    class Attribute
      class Cat < Gzr::Command
        include Gzr::Attribute
        include Gzr::FileHelper
        def initialize(attr,options)
          super()
          @attr = attr
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning(@options) if @options[:debug]
          with_session do
            f = @options[:fields]
            id = @attr if /^\d+$/.match @attr
            attr = nil
            if id
              attr = query_user_attribute(id,f)
            else
              attr = get_attribute_by_name(@attr,f)
            end
            raise(Gzr::CLI::Error, "Attribute #{@attr} does not exist") unless attr
            write_file(@options[:dir] ? "Attribute_#{attr[:id]}_#{attr[:name]}.json" : nil, @options[:dir],nil, output) do |f|
              f.puts JSON.pretty_generate(attr)
            end
          end
        end
      end
    end
  end
end
