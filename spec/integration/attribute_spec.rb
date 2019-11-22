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

RSpec.describe "`gzr attribute` command", type: :cli do
  it "executes `gzr help attribute` command successfully" do
    output = `gzr help attribute`
    expected_output = <<-OUT
Commands:
  gzr attribute cat ATTR_ID|ATTR_NAME                                        # Output json information about an attribute to screen or file
  gzr attribute create ATTR_NAME [ATTR_LABEL] [OPTIONS]                      # Create or modify an attribute
  gzr attribute get_group_value GROUP_ID|GROUP_NAME ATTR_ID|ATTR_NAME        # Retrieve a user attribute value for a group
  gzr attribute help [COMMAND]                                               # Describe subcommands or one specific subcommand
  gzr attribute import FILE                                                  # Import a user attribute from a file
  gzr attribute ls                                                           # List all the defined user attributes
  gzr attribute rm ATTR_ID|ATTR_NAME                                         # Delete a user attribute
  gzr attribute set_group_value GROUP_ID|GROUP_NAME ATTR_ID|ATTR_NAME VALUE  # Set a user attribute value for a group

    OUT

    expect(output).to eq(expected_output)
  end
end
