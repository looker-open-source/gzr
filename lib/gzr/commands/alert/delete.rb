# The MIT License (MIT)

# Copyright (c) 2023 Mike DeAngelo Looker Data Sciences, Inc.

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
require_relative '../../modules/alert'

module Gzr
  module Commands
    class Alert
      class Delete < Gzr::Command
        include Gzr::Alert
        def initialize(alert_id,options)
          super()
          @alert_id = alert_id
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning(@options) if @options[:debug]
          with_session do
           delete_alert(@alert_id)
          end
        end
      end
    end
  end
end
