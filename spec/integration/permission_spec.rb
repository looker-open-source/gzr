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

RSpec.describe "`gzr permission` command", type: :cli do
  it "executes `gzr help permission` command successfully" do
    output = `gzr help permission`
    expected_output = <<-OUT
Commands:
  gzr permission help [COMMAND]    # Describe subcommands or one specific subcommand
  gzr permission ls                # List all available permissions
  gzr permission set [SUBCOMMAND]  # Commands pertaining to permission sets
  gzr permission tree              # List all available permissions in a tree
  gzr set help [COMMAND]           # Describe subcommands or one specific subcommand
  gzr set ls                       # List the permission sets in this server.

    OUT

    expect(output).to eq(expected_output)
  end
end
