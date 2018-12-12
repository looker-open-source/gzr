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

require 'gzr/commands/user/me'

RSpec.describe Gzr::Commands::User::Me do
  it "executes `me` command successfully" do
    require 'sawyer'
    mock_response = double(Sawyer::Resource, { :id=>1, :last_name=>"foo", :first_name=>"bar", :email=>"fbar@my.company.com" })
    allow(mock_response).to receive(:to_attrs).and_return({ :id=>1, :last_name=>"foo", :first_name=>"bar", :email=>"fbar@my.company.com" })
    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:me) do |fields| 
      return mock_response
    end
    output = StringIO.new
    options = { :fields=>'id,last_name,first_name,email' }
    command = Gzr::Commands::User::Me.new(options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq <<-OUT
+--+---------+----------+-------------------+
|id|last_name|first_name|email              |
+--+---------+----------+-------------------+
| 1|foo      |bar       |fbar@my.company.com|
+--+---------+----------+-------------------+
    OUT
  end
end
