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

require 'gzr/commands/dashboard/import'

module Gzr
  class CLI
    Error = Class.new(StandardError)
  end
end

class HashResponse
  def initialize(doc)
    @doc = doc
  end

  def to_attrs
    @doc
  end

  def method_missing(m, *args, &block)
    if @doc.respond_to?(m)
      @doc.send(m, *args, &block)
    else
      @doc.fetch(m,nil)
    end
  end
end

RSpec.describe Gzr::Commands::Dashboard::Import do
  me_response_doc = { :id=>1000, :first_name=>"John", :last_name=>"Jones", :email=>"jjones@example.com" }.freeze

  dash_response_doc = {
      :id=>500,
      :title=>"Original Dash",
      :description=> "Description of the Dash",
      :slug=> "123xyz",
      :space_id=> 1,
      :dashboard_filters=>[],
      :dashboard_elements=>[],
      :dashboard_layouts=>[]
    }.freeze

  operations = {
      "create_dashboard"=>
      {
        :info=>{
          :parameters=>[
            {
              :in=>"body",
              :schema=>{ :$ref=>"#/definitions/Dashboard" }
            }
          ]
        }
      },
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

  swagger = JSON.parse(<<-SWAGGER, {:symbolize_names => true}).freeze
    { "definitions": {
      "Dashboard": {
          "properties": {
            "title": {
              "type": "string",
              "description": "Look Title",
              "x-looker-nullable": true
            },
            "description": {
              "type": "string",
              "description": "Description",
              "x-looker-nullable": true
            },
            "hidden": {
              "type": "boolean",
              "description": "Is Hidden",
              "x-looker-nullable": false
            },
            "refresh_interval": {
              "type": "string",
              "description": "Refresh Interval",
              "x-looker-nullable": true
            },
            "load_configuration": {
              "type": "string",
              "x-looker-nullable": true
            },
            "space_id": {
              "type": "string",
              "description": "Id of Space",
              "x-looker-nullable": true
            },
            "show_title": {
              "type": "boolean",
              "description": "Show title",
              "x-looker-nullable": false
            },
            "title_color": {
              "type": "string",
              "description": "Title color",
              "x-looker-nullable": true
            },
            "show_filters_bar": {
              "type": "boolean",
              "x-looker-nullable": false
            },
            "tile_background_color": {
              "type": "string",
              "description": "Tile background color",
              "x-looker-nullable": true
            },
            "tile_text_color": {
              "type": "string",
              "description": "Tile text color",
              "x-looker-nullable": true
            },
            "text_tile_text_color": {
              "type": "string",
              "description": "Color of text on text tiles",
              "x-looker-nullable": true
            },
            "deleted": {
              "type": "boolean",
              "description": "Whether or not a dashboard is deleted.",
              "x-looker-nullable": false
            },
            "query_timezone": {
              "type": "string",
              "description": "Timezone in which the Dashboard will run by default.",
              "x-looker-nullable": true
            }
          },
          "x-looker-status": "beta"
        }
      }
    }
    SWAGGER

  define_method :mock_sdk do |block_hash={}|
    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:authenticated?) { true }
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:operations) { operations }
    mock_sdk.define_singleton_method(:swagger) { swagger }
    mock_sdk.define_singleton_method(:me) do |req|
      HashResponse.new(me_response_doc)
    end
    mock_sdk.define_singleton_method(:create_dashboard) do |req|
      if block_hash && block_hash[:create_dashboard]
        block_hash[:create_dashboard].call(req)
      end
      doc = dash_response_doc.dup
      doc[:id] += 1
      HashResponse.new(doc)
    end
    mock_sdk.define_singleton_method(:update_dashboard) do |id,req|
      if block_hash && block_hash[:update_dashboard]
        block_hash[:update_dashboard].call(id,req)
      end
      doc = dash_response_doc.dup
      doc.merge!(req)
      doc[:id] = id
      HashResponse.new(doc)
    end
    mock_sdk.define_singleton_method(:search_dashboards) do |req|
      if req&.fetch(:slug,nil) == dash_response_doc[:slug] && req&.fetch(:space_id,nil) == dash_response_doc[:space_id]
        [HashResponse.new(dash_response_doc)]
      elsif req&.fetch(:slug,nil) == dash_response_doc[:slug] && !req.has_key?(:space_id)
        [HashResponse.new(dash_response_doc)]
      elsif "dupe".eql?(req&.fetch(:slug,nil)) && !req.has_key?(:space_id)
        doc = dash_response_doc.dup
        doc[:id] = 201
        doc[:space_id] = 2
        doc[:slug] = "dupe"
        [HashResponse.new(doc)]
      elsif req&.fetch(:title,nil) == dash_response_doc[:title] && req&.fetch(:space_id,nil) == dash_response_doc[:space_id]
        [HashResponse.new(dash_response_doc)]
      else
        []
      end
    end
    mock_sdk
  end

  it "executes `import` when no conflicting dashboards exist" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Dashboard::Import.new(StringIO.new('{ "id": "101", "title": "New Dash", "description": "Description of the Dash", "dashboard_filters": [], "dashboard_elements": [], "dashboard_layouts": [] }'), 1, options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq("Imported dashboard 501\n")
  end

  it "executes `import` and gets exception when there is another dashboard of different name but same slug" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Dashboard::Import.new(StringIO.new('{ "id": "101", "title": "New Dash", "slug": "123xyz", "description": "Description of the Dash", "dashboard_filters": [], "dashboard_elements": [], "dashboard_layouts": [] }'), 1, options)

    command.instance_variable_set(:@sdk, mock_sdk)

    expect { command.execute(output: output) }.to raise_error(/Use --force/)
  end

  it "executes `import` and gets exception when there is another dashboard of same name" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Dashboard::Import.new(StringIO.new('{ "id": "101", "title": "Original Dash", "slug": "abc123", "description": "Description of the Dash", "dashboard_filters": [], "dashboard_elements": [], "dashboard_layouts": [] }'), 1, options)

    command.instance_variable_set(:@sdk, mock_sdk)

    expect { command.execute(output: output) }.to raise_error(/Use --force/)
  end

  it "executes `import` and succeeds with force when there is another dashboard of different name but same slug" do
    output = StringIO.new
    options = {:force=>true}
    command = Gzr::Commands::Dashboard::Import.new(StringIO.new('{ "id": "101", "title": "New Dash", "slug": "123xyz", "description": "Description of the Dash", "dashboard_filters": [], "dashboard_elements": [], "dashboard_layouts": [] }'), 1, options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)
    expect(output.string).to end_with("Imported dashboard 500\n")
  end

  it "executes `import` and succeeds when there is a duplicate slug" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Dashboard::Import.new(StringIO.new('{ "id": "101", "title": "New Dash", "slug": "dupe", "description": "Description of the Dash", "dashboard_filters": [], "dashboard_elements": [], "dashboard_layouts": [] }'), 1, options)
    block_hash = {:create_dashboard =>
      Proc.new do |req|
        expect(req).not_to include(:slug => "dupe")
      end
    }
    command.instance_variable_set(:@sdk, mock_sdk(block_hash))

    command.execute(output: output)
    expect(output.string).to end_with("Imported dashboard 501\n")
  end

  it "executes `import` and succeeds with force when there is another dashboard of same name" do
    output = StringIO.new
    options = {:force=>true}
    command = Gzr::Commands::Dashboard::Import.new(StringIO.new('{ "id": "101", "title": "Original Dash", "slug": "abc123", "description": "Description of the Dash", "dashboard_filters": [], "dashboard_elements": [], "dashboard_layouts": [] }'), 1, options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)
    expect(output.string).to end_with("Imported dashboard 500\n")
  end
end
