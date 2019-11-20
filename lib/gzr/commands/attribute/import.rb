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

require_relative '../../command'
require_relative '../../modules/attribute'
require_relative '../../modules/filehelper'

module Gzr
  module Commands
    class Attribute
      class Import < Gzr::Command
        include Gzr::Attribute
        include Gzr::FileHelper
        def initialize(file,options)
          super()
          @file = file
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning(@options) if @options[:debug]
          with_session do
            read_file(@file) do |source|
              name_used = get_attribute_by_name(source[:name])
              if name_used
                raise(Gzr::CLI::Error, "Attribute #{source[:name]} already exists and can't be modified") if name_used[:is_system]
                raise(Gzr::CLI::Error, "Attribute #{source[:name]} already exists\nUse --force if you want to overwrite it") unless @options[:force]
              end

              label_used = get_attribute_by_label(source[:label])
              if name_used
                raise(Gzr::CLI::Error, "Attribute with label #{source[:label]} already exists and can't be modified") if name_used[:is_system]
                raise(Gzr::CLI::Error, "Attribute with label #{source[:label]} already exists\nUse --force if you want to overwrite it") unless @options[:force]
              end

              attr = nil
              if name_used
                upd_attr = source.select do |k,v|
                  keys_to_keep('update_user_attribute').include?(k) && !(name_used[k] == v)
                end

                attr = update_attribute(name_used.id,upd_attr)
              else
                new_attr = source.select do |k,v|
                  (keys_to_keep('create_user_attribute') - [:hidden_value_domain_whitelist]).include? k
                end
                new_attr[:hidden_value_domain_whitelist] = source[:hidden_value_domain_whitelist] if source[:value_is_hidden]

                attr = create_attribute(new_attr)
              end
              output.puts "Imported attribute #{attr.name} #{attr.id}" unless @options[:plain] 
              output.puts attr.id if @options[:plain] 
            end
          end
        end
      end
    end
  end
end
