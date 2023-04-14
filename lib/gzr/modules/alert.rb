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

module Gzr
  module Alert
    def get_alert(alert_id)
      data = nil
      begin
        data = @sdk.get_alert(alert_id)
      rescue LookerSDK::NotFound => e
        # do nothing
      rescue LookerSDK::Error => e
        say_error "Error querying user_attribute(#{attr_id},#{JSON.pretty_generate(req)})"
        say_error e
        raise
      end
      data
    end

    def search_alerts(fields=nil)
      data = nil
      begin
        req = {}
        req[:fields] = fields if fields
        data = @sdk.search_alerts(req)
      rescue LookerSDK::NotFound => e
        # do nothing
      rescue LookerSDK::Error => e
        say_error "Error querying alerts(#{JSON.pretty_generate(req)})"
        say_error e
        raise
      end
      data
    end
  end
end
