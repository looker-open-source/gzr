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

RSpec.describe "`gzr role` command", type: :cli do
  it "executes `gzr help role` command successfully" do
    output = `gzr help role`
    expected_output = <<-OUT
Commands:
  gzr role cat ROLE_ID                                       # Output the JSON representation of a role to screen/file
  gzr role create ROLE_NAME PERMISSION_SET_ID MODEL_SET_ID   # Create new role with the given permission and model sets
  gzr role group_add ROLE_ID GROUP_ID GROUP_ID GROUP_ID ...  # Add indicated groups to role
  gzr role group_ls ROLE_ID                                  # List the groups assigned to a role
  gzr role group_rm ROLE_ID GROUP_ID GROUP_ID GROUP_ID ...   # Remove indicated groups from role
  gzr role help [COMMAND]                                    # Describe subcommands or one specific subcommand
  gzr role ls                                                # Display all roles
  gzr role rm ROLE_ID                                        # Delete a role
  gzr role user_add ROLE_ID USER_ID USER_ID USER_ID ...      # Add indicated users to role
  gzr role user_ls ROLE_ID                                   # List the users assigned to a role
  gzr role user_rm ROLE_ID USER_ID USER_ID USER_ID ...       # Remove indicated users from role

    OUT

    expect(output).to eq(expected_output)
  end
end
