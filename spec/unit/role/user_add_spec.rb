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

require 'gzr/commands/role/user_add'

RSpec.describe Gzr::Commands::Role::UserAdd do
  it "executes `role user_add` command successfully" do
    require 'sawyer'
    users = (100..105).collect do |i|
      user_doc = {
          :id=>i
      }
      mock_user = double(Sawyer::Resource, user_doc)
      allow(mock_user).to receive(:to_attrs).and_return(user_doc)
      mock_user
    end
    mock_sdk = Object.new
    allow(mock_sdk).to receive(:logout)
    allow(mock_sdk).to receive(:role_users) do |role_id,body|
      users
    end
    allow(mock_sdk).to receive(:set_role_users) do |role_id,body|
      expect(body).to contain_exactly(100, 101, 102, 103, 104, 105, 106)
      nil
    end
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Role::UserAdd.new(1,[106],options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq("")
  end
end
