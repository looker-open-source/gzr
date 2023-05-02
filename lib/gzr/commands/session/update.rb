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
require_relative '../../modules/session'

module Gzr
  module Commands
    class Session
      class Update < Gzr::Command
        include Gzr::Session
        def initialize(workspace_id,options)
          super()
          @options = options
          @workspace_id = workspace_id
        end

        def execute(input: $stdin, output: $stdout)
          say_warning(@options) if @options[:debug]
          if !@options[:token] && !@options[:token_file]
            say_warning "Setting the session workspace_id only makes sense with a persistent session using --token or --token_file options"
          end
          with_session do
            auth = update_auth(@workspace_id)
            output.puts JSON.pretty_generate(auth)
          end
        end
      end
    end
  end
end
