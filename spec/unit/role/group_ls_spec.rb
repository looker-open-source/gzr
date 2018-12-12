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

require 'gzr/commands/role/group_ls'

RSpec.describe Gzr::Commands::Role::GroupLs do
  it "executes `role group_ls` command successfully" do
    require 'sawyer'
    groups = (100..105).collect do |i|
      group_doc = {
          :id=>i,
          :name=>"Group No#{i}",
      }
      mock_group = double(Sawyer::Resource, group_doc)
      allow(mock_group).to receive(:to_attrs).and_return(group_doc)
      mock_group
    end
    mock_sdk = Object.new
    allow(mock_sdk).to receive(:logout)
    allow(mock_sdk).to receive(:role_groups) do |role_id,body|
      groups
    end
    output = StringIO.new
    options = { :fields=>'id,name' }
    command = Gzr::Commands::Role::GroupLs.new(1,options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq <<-OUT
+---+-----------+
| id|name       |
+---+-----------+
|100|Group No100|
|101|Group No101|
|102|Group No102|
|103|Group No103|
|104|Group No104|
|105|Group No105|
+---+-----------+
    OUT
  end
end
