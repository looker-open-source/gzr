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

RSpec.describe "`gzr plan` command", type: :cli do
  it "executes `gzr help plan` command successfully" do
    output = `gzr help plan`
    expected_output = <<-OUT
Commands:
  gzr plan cat PLAN_ID                       # Output the JSON representation of a scheduled plan to the screen or a file
  gzr plan disable PLAN_ID                   # Disable the specified plan
  gzr plan enable PLAN_ID                    # Enable the specified plan
  gzr plan failures                          # Report all plans that failed in their most recent run attempt
  gzr plan help [COMMAND]                    # Describe subcommands or one specific subcommand
  gzr plan import PLAN_FILE OBJ_TYPE OBJ_ID  # Import a plan from a file
  gzr plan ls                                # List the scheduled plans on a server
  gzr plan rm PLAN_ID                        # Delete a scheduled plan
  gzr plan runit PLAN_ID                     # Execute a saved plan immediately

    OUT

    expect(output).to eq(expected_output)
  end
end
