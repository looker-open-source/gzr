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

require 'gzr/commands/space/export'

RSpec.describe Gzr::Commands::Space::Export do
  require 'sawyer'
  require 'rubygems/package'

  it "executes `export` command successfully" do
    look_response_docs = [
      { 
        :id=>2,
        :title=>"bar"
      },
      {
        :id=>5,
        :title=>"bar"
      }
    ]
    mock_look_responses = look_response_docs.collect { |l| double(Sawyer::Resource, l) }
    mock_look_responses.each_index { |i| allow(mock_look_responses[i]).to receive(:to_attrs).and_return(look_response_docs[i]) }

    dashboard_response_docs = [
      {
        :id=>3,
        :title=>"bar",
        :dashboard_elements=>[]
      },
      {
        :id=>6,
        :title=>"bar",
        :dashboard_elements=>[]
      }
    ]
    mock_dashboard_responses = dashboard_response_docs.collect { |d| double(Sawyer::Resource, d) }
    mock_dashboard_responses.each_index { |i| allow(mock_dashboard_responses[i]).to receive(:to_attrs).and_return(dashboard_response_docs[i]) }

    space_response_docs = [
      {
        :id=>1,
        :name=>"foo",
        :parent_id=>0,
        :looks=>[
          mock_look_responses[0]
        ],
        :dashboards=>[
          mock_dashboard_responses[0]
        ]
      },
      {
        :id=>4,
        :name=>"buz",
        :parent_id=>1,
        :looks=>[
          mock_look_responses[1]
        ],
        :dashboards=>[
          mock_dashboard_responses[1]
        ]
      }
    ]
    mock_space_responses = space_response_docs.collect { |s| double(Sawyer::Resource, s) }
    mock_space_responses.each_index { |i| allow(mock_space_responses[i]).to receive(:to_attrs).and_return(space_response_docs[i]) }

    space_child_response_doc = {
      :id=>4,
      :name=>"buz",
      :parent_id=>1,
      :looks=>[
      ],
      :dashboards=>[
      ]
    }
    mock_space_child_response = double(Sawyer::Resource, space_child_response_doc)
    allow(mock_space_child_response).to receive(:to_attrs).and_return(space_child_response_doc)

    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:space) do |space_id,req|
      return mock_space_responses[0] if space_id == 1
      return mock_space_responses[1] if space_id == 4
    end
    mock_sdk.define_singleton_method(:dashboard) do |dashboard_id|
      return mock_dashboard_responses[0] if dashboard_id == 3 
      return mock_dashboard_responses[1] if dashboard_id == 6 
    end
    mock_sdk.define_singleton_method(:look) do |look_id|
      return mock_look_responses[0] if look_id == 2 
      return mock_look_responses[1] if look_id == 5 
    end
    mock_sdk.define_singleton_method(:space_children) do |id,req|
      return [mock_space_child_response] if id == 1
      return []
    end

    output = StringIO.new
    options = {}
    command = Gzr::Commands::Space::Export.new(1,options)

    command.instance_variable_set(:@sdk, mock_sdk)

    mock_tar_writer = double(Gem::Package::TarWriter)

    mock_tar_writer.define_singleton_method(:mkdir) do |name,mode|
      output.puts "mkdir #{name},#{mode}"
    end

    mock_tar_writer.define_singleton_method(:add_file) do |name,mode|
      output.puts "add_file #{name},#{mode}"
    end

    command.process_space(1,mock_tar_writer)

    expect(output.string).to eq <<-OUT
mkdir foo,493
add_file foo/Space_1_foo.json,420
add_file foo/Look_2_bar.json,420
add_file foo/Dashboard_3_bar.json,420
mkdir foo/buz,493
add_file foo/buz/Space_4_buz.json,420
add_file foo/buz/Look_5_bar.json,420
add_file foo/buz/Dashboard_6_bar.json,420
    OUT
  end
end
