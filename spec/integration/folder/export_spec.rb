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

RSpec.describe "`gzr folder export` command", type: :cli do
  it "executes `folder export --help` command successfully" do
    output = `gzr folder export --help`
    expect(output).to eq <<-OUT
Usage:
  gzr folder export FOLDER_ID

Options:
  -h, [--help], [--no-help]    # Display usage information
      [--plans], [--no-plans]  # Include scheduled plans
      [--trim], [--no-trim]    # Trim output to minimal set of fields for later import
      [--dir=DIR]              # Directory to store output tree
                               # Default: .
      [--tar=TAR]              # Tar file to store output
      [--tgz=TGZ]              # TarGZ file to store output
      [--zip=ZIP]              # Zip file to store output

Export a folder, including all child looks, dashboards, and folders.
    OUT
  end
end
