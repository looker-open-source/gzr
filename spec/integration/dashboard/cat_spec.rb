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

RSpec.describe "`gzr dashboard cat` command", type: :cli do
  it "executes `dashboard cat --help` command successfully" do
    output = `gzr dashboard cat --help`
    expect(output).to eq <<-OUT
Usage:
  gzr dashboard cat DASHBOARD_ID

Options:
  -h, [--help], [--no-help]                        # Display usage information
      [--dir=DIR]                                  # Directory to store output file
      [--plans], [--no-plans]                      # Include scheduled plans
      [--transform=TRANSFORM]                      # Fully-qualified path to a JSON file describing the transformations to apply
      [--simple-filename], [--no-simple-filename]  # Use simple filename for output (Dashboard_<id>.json)

Output the JSON representation of a dashboard to the screen or a file
    OUT
  end
end
