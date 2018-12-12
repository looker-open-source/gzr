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

require 'gzr/commands/role/ls'

RSpec.describe Gzr::Commands::Role::Ls do
  it "executes `role ls` command successfully" do
    require 'sawyer'
    roles = (100..105).collect do |i|
      role_doc = {
          :id=>i,
          :name=>"Role #{i}"
      }
      mock_role = double(Sawyer::Resource, role_doc)
      allow(mock_role).to receive(:to_attrs).and_return(role_doc)
      mock_role
    end
    mock_sdk = Object.new
    allow(mock_sdk).to receive(:logout)
    allow(mock_sdk).to receive(:all_roles) do |body|
      roles
    end
    output = StringIO.new
    options = { :fields=>'id,name' }
    command = Gzr::Commands::Role::Ls.new(options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq <<-OUT
+---+--------+
| id|name    |
+---+--------+
|100|Role 100|
|101|Role 101|
|102|Role 102|
|103|Role 103|
|104|Role 104|
|105|Role 105|
+---+--------+
    OUT
  end
end
