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
require_relative '../../modules/look'
require_relative '../../modules/user'
require_relative '../../modules/plan'
require_relative '../../modules/filehelper'

module Gzr
  module Commands
    class Look
      class Import < Gzr::Command
        include Gzr::Look
        include Gzr::User
        include Gzr::Plan
        include Gzr::FileHelper
        def initialize(file, dest_folder_id, options)
          super()
          @file = file
          @dest_folder_id = dest_folder_id
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options[:debug]
          with_session do

            @me ||= query_me("id")

            read_file(@file) do |data|

              if data[:deleted]
                say_warning("Attempt to import a deleted look!")
                say_warning("This may result in errors.")
              end

              if data[:dashboard_elements]
                say_error("File contains dashboard_elements! Is this a dashboard?")
                raise Gzr::CLI::Error, "import file is not a valid look"
              end

              look = upsert_look(@me[:id],create_fetch_query(data[:query]).id,@dest_folder_id,data,output: output)
              upsert_plans_for_look(look.id,@me[:id],data[:scheduled_plans]) if data[:scheduled_plans]
              output.puts "Imported look #{look[:id]}" unless @options[:plain]
              output.puts look[:id] if @options[:plain]
            end
          end
        end
      end
    end
  end
end
