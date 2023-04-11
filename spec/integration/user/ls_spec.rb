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

RSpec.describe "`gzr user ls` command", type: :cli do
  it "executes `user ls --help` command successfully" do
    output = `gzr user ls --help`
    expect(output).to eq <<-OUT
Usage:
  gzr user ls

Options:
  -h, [--help], [--no-help]              # Display usage information
      [--fields=FIELDS]                  # Fields to display
                                         # Default: id,email,last_name,first_name,personal_folder_id,home_folder_id
      [--last-login], [--no-last-login]  # Include the time of the most recent login
      [--plain], [--no-plain]            # print without any extra formatting
      [--csv], [--no-csv]                # output in csv format per RFC4180

list all users
    OUT
  end
end
