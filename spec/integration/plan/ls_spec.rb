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

RSpec.describe "`gzr plan ls` command", type: :cli do
  it "executes `gzr plan help ls` command successfully" do
    output = `gzr plan help ls`
    expected_output = <<-OUT
Usage:
  gzr plan ls

Options:
  -h, [--help], [--no-help]          # Display usage information
      [--fields=FIELDS]              # Fields to display
                                     # Default: id,enabled,name,user(id,display_name),look_id,dashboard_id,lookml_dashboard_id,crontab
      [--disabled], [--no-disabled]  # Retrieve disable plans
      [--plain], [--no-plain]        # print without any extra formatting
      [--csv], [--no-csv]            # output in csv format per RFC4180

List the scheduled plans on a server
    OUT

    expect(output).to eq(expected_output)
  end
end
