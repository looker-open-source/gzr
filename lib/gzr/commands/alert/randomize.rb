# The MIT License (MIT)

# Copyright (c) 2024 Mike DeAngelo Google, Inc.

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
require_relative '../../modules/user'
require_relative '../../modules/cron'

module Gzr
  module Commands
    class Alert
      class Randomize < Gzr::Command
        include Gzr::Alert
        include Gzr::User
        include Gzr::Cron
        def initialize(options)
          super()
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning(@options) if @options[:debug]

          window = @options[:window]
          if window < 1 or window > 60
            say_error("window must be between 1 and 60")
            raise Gzr::CLI::Error.new()
          end

          with_session do
            @me ||= query_me("id")

            req = {}
            req[:disabled] = false
            req[:all_owners] = @options[:all] unless @options[:all].nil?
            alerts = search_alerts(**req)
            begin
              say_ok "No alerts found"
              return nil
            end unless alerts && alerts.length > 0

            alerts.each do |alert|
              crontab = alert[:cron]
              if crontab == ""
                say_warning("skipping alert #{alert[:id]} with no cron")
                next
              end
              crontab = randomize_cron(crontab, window)
              begin
                alert[:cron] = crontab
                update_alert(alert[:id], alert)
              rescue LookerSDK::UnprocessableEntity => e
                say_warning("Skipping invalid entry")
              end
            end

          end
        end
      end
    end
  end
end
