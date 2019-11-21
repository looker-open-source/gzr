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
require_relative '../../modules/attribute'

module Gzr
  module Commands
    class Attribute
      class Create < Gzr::Command
        include Gzr::Attribute
        def initialize(name,label,options)
          super()
          @name = name
          @label = label || @name.split(/ |\_|\-/).map(&:capitalize).join(" ")
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning(@options) if @options[:debug]
          with_session do
            source = { :name=>@name, :label=>@label, :type=>@options[:type] }
            source[:'default_value'] = @options[:'default-value'] if @options[:'default-value']
            source[:'value_is_hidden'] = true if @options[:'is-hidden']
            source[:'user_can_view'] = true if @options[:'can-view']
            source[:'user_can_edit'] = true if @options[:'can-edit']
            source[:'hidden_value_domain_whitelist'] = @options[:'domain-whitelist'] if @options[:'is-hidden'] && @options[:'domain-whitelist']

            attr = upsert_user_attribute(source, @options[:force], output: $stdout)
            output.puts "Imported attribute #{attr.name} #{attr.id}" unless @options[:plain] 
            output.puts attr.id if @options[:plain] 
          end
        end
      end
    end
  end
end
