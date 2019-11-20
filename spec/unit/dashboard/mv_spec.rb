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

require 'gzr/commands/dashboard/mv'

RSpec.describe Gzr::Commands::Dashboard::Mv do
  dash_response_doc = {
      :id=>500,
      :title=>"Original Dash",
      :description=> "Description of the Dash",
      :slug=> "123xyz",
      :space_id=> 1,
      :deleted=> false,
      :dashboard_filters=>[],
      :dashboard_elements=>[],
      :dashboard_layouts=>[]
    }.freeze

  operations = {
      "update_dashboard"=>
      {
        :info=>{
          :parameters=>[
            {
              "name": "dashboard_id",
              "in": "path",
              "description": "Id of dashboard",
              "required": true,
              "type": "string"
            },
            {
              :in=>"body",
              :schema=>{ :$ref=>"#/definitions/Dashboard" }
            }
          ]
        }
      }
    }.freeze

  define_method :mock_sdk do |block_hash={}|
    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:authenticated?) { true }
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:operations) { operations }
    mock_sdk.define_singleton_method(:dashboard) do |id|
      if block_hash && block_hash[:dashboard]
        block_hash[:dashboard].call(id)
      end
      doc = dash_response_doc.dup
      HashResponse.new(doc)
    end

    mock_sdk.define_singleton_method(:update_dashboard) do |id,req|
      if block_hash && block_hash[:update_dashboard]
        block_hash[:update_dashboard].call(id,req)
      end
      doc = dash_response_doc.dup
      doc.merge!(req)
      HashResponse.new(doc)
    end
    mock_sdk.define_singleton_method(:search_dashboards) do |req|
      if req&.fetch(:space_id,nil) == 2 && req&.fetch(:title,nil) == 'Original Dash'
        []
      end
    end
    mock_sdk
  end

  it "executes `mv` when no conflicting dashboards exist" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Dashboard::Mv.new(500, 2, options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq("Moved dashboard 500 to space 2\n")
  end

end
