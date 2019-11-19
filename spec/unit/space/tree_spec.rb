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

require 'gzr/commands/space/tree'

RSpec.describe Gzr::Commands::Space::Tree do
  me_response_doc = {
    :id=>1000,
    :first_name=>"John",
    :last_name=>"Jones",
    :email=>"jjones@example.com",
    :home_space_id=>314159,
    :personal_space_id=>1088
  }.freeze

  mock_spaces = Array.new
  mock_spaces << {
    :id=>1,
    :name=>"Space 1",
    :looks=>[ ],
    :dashboards=>[ ],
    :parent_id=>nil
  }
  mock_spaces << {
    :id=>2,
    :name=>"Space 2",
    :looks=>[
      HashResponse.new({:id=>101, :title=>"Look 101"}),
      HashResponse.new({:id=>102, :title=>"Look 102"})
    ],
    :dashboards=>[
      HashResponse.new({:id=>201, :title=>"Dash 201"}),
      HashResponse.new({:id=>202, :title=>"Dash 202"})
    ],
    :parent_id=>1
  }
  mock_spaces << {
    :id=>5,
    :name=>"Space 5",
    :looks=>[
      HashResponse.new({:id=>105, :title=>"Look 105"}),
      HashResponse.new({:id=>106, :title=>"Look 106 with / in name"})
    ],
    :dashboards=>[
      HashResponse.new({:id=>205, :title=>"Dash 205"}),
      HashResponse.new({:id=>206, :title=>"Dash 206 with / in name"})
    ],
    :parent_id=>1
  }
  mock_spaces << {
    :id=>3,
    :name=>"Space with / in name",
    :looks=>[
      HashResponse.new({:id=>103, :title=>"Look 103"}),
      HashResponse.new({:id=>104, :title=>"Look 104 with / in name"})
    ],
    :dashboards=>[
      HashResponse.new({:id=>203, :title=>"Dash 203"}),
      HashResponse.new({:id=>204, :title=>"Dash 204 with / in name"})
    ],
    :parent_id=>2
  }
  mock_spaces << {
    :id=>4,
    :name=>nil,
    :looks=>[],
    :dashboards=>[ ],
    :parent_id=>2
  }

  define_method :mock_sdk do |block_hash={}|
    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:authenticated?) { true }
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:me) do |req|
      HashResponse.new(me_response_doc)
    end
    mock_sdk.define_singleton_method(:search_spaces) do |req|
      if block_hash && block_hash[:search_spaces]
        block_hash[:search_spaces].call(req)
      end
      doc = dash_response_doc.dup
      doc[:id] += 1
      HashResponse.new(doc)
    end
    mock_sdk.define_singleton_method(:space) do |id,req|
      if block_hash && block_hash[:space]
        block_hash[:space].call(id,req)
      end
      docs = mock_spaces.select {|s| s[:id] == id}
      return HashResponse.new(docs.first) unless docs.empty?
      nil
    end
    mock_sdk.define_singleton_method(:space_children) do |id,req|
      if block_hash && block_hash[:space_children]
        block_hash[:space_children].call(id,req)
      end
      docs = mock_spaces.select {|s| s[:parent_id] == id}
      return docs.map {|d| HashResponse.new(d)}
    end
    mock_sdk
  end

  it "executes `tree` command successfully" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Space::Tree.new("1",options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq <<-OUT
Space 1
└── Space 2
    ├── Space with / in name
    │   ├── (l) Look 103
    │   ├── (l) Look 104 with / in name
    │   ├── (d) Dash 203
    │   └── (d) Dash 204 with / in name
    ├── nil (4)
    ├── (l) Look 101
    ├── (l) Look 102
    ├── (d) Dash 201
    └── (d) Dash 202
└── Space 5
    ├── (l) Look 105
    ├── (l) Look 106 with / in name
    ├── (d) Dash 205
    └── (d) Dash 206 with / in name
    OUT
  end
end
