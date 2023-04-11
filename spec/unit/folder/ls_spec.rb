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

require 'gzr/commands/folder/ls'

RSpec.describe Gzr::Commands::Folder::Ls do
  it "executes `folder ls` command successfully" do
    require 'sawyer'
    resp_hash = {
      :id=>1,
      :name=>"foo",
      :parent_id=>0,
      :looks=>[
        {
          :id=>2,
          :title=>"bar"
        }
      ],
      :dashboards=>[
        {
          :id=>3,
          :title=>"baz"
        }
      ]
    }
    mock_response = double(Sawyer::Resource, resp_hash)
    allow(mock_response).to receive(:to_attrs).and_return(resp_hash)
    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:folder) do |look_id,req|
      return mock_response
    end
    resp_hash2 = {
      :id=>4,
      :name=>"buz",
      :parent_id=>1
    }
    mock_response2 = double(Sawyer::Resource, resp_hash2)
    allow(mock_response2).to receive(:to_attrs).and_return(resp_hash2)
    mock_sdk.define_singleton_method(:folder_children) do |look_id,req|
      return [mock_response2]
    end

    output = StringIO.new
    options = { :fields=>'parent_id,id,name,looks(id,title),dashboards(id,title)' }
    command = Gzr::Commands::Folder::Ls.new("1", options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq <<-OUT
+---------+--+----+--------+-----------+-------------+----------------+
|parent_id|id|name|looks.id|looks.title|dashboards.id|dashboards.title|
+---------+--+----+--------+-----------+-------------+----------------+
|        0| 1|foo |        |           |             |                |
|        1| 4|buz |        |           |             |                |
|         |  |    |       2|bar        |             |                |
|         |  |    |        |           |            3|baz             |
+---------+--+----+--------+-----------+-------------+----------------+
    OUT
  end
end
