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

require 'gzr/commands/look/import'

RSpec.describe Gzr::Commands::Look::Import do
  me_response_doc = { :id=>1000, :first_name=>"John", :last_name=>"Jones", :email=>"jjones@example.com" }.freeze

  query_response_doc = { :id=>555 }.freeze

  look_response_doc = {
    :id => 31415,
    :title => "Daily Profit",
    :description => "Total profit by day for the last 100 days",
    :query_id => 555,
    :user_id => 1000,
    :space_id => 1,
    :slug => "123xyz"
  }.freeze

  operations = {
    :create_query => {
      :info => {
        :parameters => [
          {
            :in => "body",
            :schema => { :$ref=>"#/definitions/Query" }
          }
        ]
      }
    },
    :create_look => {
      :info => {
        :parameters => [
          {
            :in => "body",
            :schema => { :$ref=>"#/definitions/Look" }
          }
        ]
      }
    },
    :update_look => {
      :info => {
        :parameters => [
          {
              "name": "look_id",
              "in": "path",
              "description": "Id of look",
              "required": true,
              "type": "integer",
              "format": "int64"
          },
          {
            :in => "body",
            :schema => { :$ref=>"#/definitions/Look" }
          }
        ]
      }
    }
  }.freeze

  swagger = JSON.parse(<<-SWAGGER, {:symbolize_names => true}).freeze
    {
      "definitions": {
        "Query": {
          "properties": {
            "model": {
              "type": "string",
              "description": "Model",
              "x-looker-nullable": false
            },
            "view": {
              "type": "string",
              "description": "View",
              "x-looker-nullable": false
            },
            "fields": {
              "type": "array",
              "items": {
                "type": "string"
              },
              "description": "Fields",
              "x-looker-nullable": true
            },
            "pivots": {
              "type": "array",
              "items": {
                "type": "string"
              },
              "description": "Pivots",
              "x-looker-nullable": true
            },
            "fill_fields": {
              "type": "array",
              "items": {
                "type": "string"
              },
              "description": "Fill Fields",
              "x-looker-nullable": true
            },
            "filters": {
              "type": "object",
              "additionalProperties": {
                "type": "string"
              },
              "description": "Filters",
              "x-looker-nullable": true
            },
            "filter_expression": {
              "type": "string",
              "description": "Filter Expression",
              "x-looker-nullable": true
            },
            "sorts": {
              "type": "array",
              "items": {
                "type": "string"
              },
              "x-looker-nullable": true
            },
            "limit": {
              "type": "string",
              "description": "Limit",
              "x-looker-nullable": true
            },
            "column_limit": {
              "type": "string",
              "description": "Column Limit",
              "x-looker-nullable": true
            },
            "total": {
              "type": "boolean",
              "description": "Total",
              "x-looker-nullable": false
            },
            "row_total": {
              "type": "string",
              "description": "Raw Total",
              "x-looker-nullable": true
            },
            "runtime": {
              "type": "number",
              "format": "double",
              "description": "Runtime",
              "x-looker-nullable": true
            },
            "vis_config": {
              "type": "object",
              "additionalProperties": {
                "type": "string",
                "format": "any"
              },
              "x-looker-nullable": true
            },
            "filter_config": {
              "type": "object",
              "additionalProperties": {
                "type": "string",
                "format": "any"
              },
              "x-looker-nullable": true
            },
            "visible_ui_sections": {
              "type": "string",
              "description": "Visible UI Sections",
              "x-looker-nullable": true
            },
            "dynamic_fields": {
              "type": "array",
              "items": {
                "type": "string",
                "format": "any"
              },
              "description": "Dynamic Fields",
              "x-looker-nullable": true
            },
            "client_id": {
              "type": "string",
              "x-looker-nullable": true
            },
            "query_timezone": {
              "type": "string",
              "description": "Query Timezone",
              "x-looker-nullable": true
            }
          },
          "x-looker-status": "stable",
          "required": [
            "model",
            "view"
          ]
        },
        "Look": {
          "properties": {
            "title": {
              "type": "string",
              "description": "Look Title",
              "x-looker-nullable": true
            },
            "query_id": {
              "type": "integer",
              "format": "int64",
              "description": "Query Id",
              "x-looker-nullable": true
            },
            "description": {
              "type": "string",
              "description": "Description",
              "x-looker-nullable": true
            },
            "user_id": {
              "type": "integer",
              "format": "int64",
              "description": "User Id",
              "x-looker-nullable": true
            },
            "space_id": {
              "type": "string",
              "description": "Space Id",
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
    mock_sdk.define_singleton_method(:create_query) do |req|
      if block_hash && block_hash[:create_query]
        block_hash[:create_query].call(req)
      end
      doc = query_response_doc.dup
      doc[:id] += 1
      HashResponse.new(doc)
    end
    mock_sdk.define_singleton_method(:create_look) do |req|
      if block_hash && block_hash[:create_look]
        block_hash[:create_look].call(req)
      end
      doc = look_response_doc.dup
      doc.merge!(req)
      doc[:id] += 1
      HashResponse.new(doc)
    end
    mock_sdk.define_singleton_method(:update_look) do |id,req|
      if block_hash && block_hash[:update_look]
        block_hash[:update_look].call(id,req)
      end
      doc = look_response_doc.dup
      doc.merge!(req)
      doc[:id] = id
      HashResponse.new(doc)
    end
    mock_sdk.define_singleton_method(:search_looks) do |req|
      if req&.fetch(:slug,nil) == look_response_doc[:slug] && req&.fetch(:space_id,nil) == look_response_doc[:space_id]
        [HashResponse.new(look_response_doc)]
      elsif req&.fetch(:slug,nil) == look_response_doc[:slug] && !req.has_key?(:space_id)
        [HashResponse.new(look_response_doc)]
      elsif "DeletedSlug".eql?(req&.fetch(:slug,nil)) && req[:deleted]
        doc = look_response_doc.dup
        doc[:id] = 201
        doc[:space_id] = 2
        doc[:slug] = "DeletedSlug"
        doc[:deleted] = true
        [HashResponse.new(doc)]
      elsif "dupe".eql?(req&.fetch(:slug,nil)) && !req.has_key?(:space_id)
        doc = look_response_doc.dup
        doc[:id] = 201
        doc[:space_id] = 2
        doc[:slug] = "dupe"
        [HashResponse.new(doc)]
      elsif req&.fetch(:title,nil) == look_response_doc[:title] && req&.fetch(:space_id,nil) == look_response_doc[:space_id]
        [HashResponse.new(look_response_doc)]
      else
        []
      end
    end
    mock_sdk
  end

  it "executes `import` command successfully" do
    output = StringIO.new
    file = nil
    options = {}

    command = Gzr::Commands::Look::Import.new(StringIO.new( <<-LOOK
      {
        "id": 198,
        "query_id": 90961,
        "title": "New Look",
        "query": {
          "id": 90961,
          "view": "order_items",
          "fields": [
            "orders.created_date",
            "orders.total_profit"
          ],
          "sorts": [
            "orders.created_date desc"
          ],
          "limit": "500",
          "column_limit": "50",
          "total": null,
          "row_total": null,
          "model": "ecommerce"
        },
        "model": {
          "id": "ecommerce",
          "label": "Ecommerce"
        },
        "deleted": false,
        "public": null
      }
    LOOK
    ), 1, options)

    block_hash = {:create_look =>
      Proc.new do |req|
        expect(req).not_to include(:deleted => true)
        expect(req).to include(:space_id => 1)
        expect(req).not_to include(:folder_id)
      end
    }
    command.instance_variable_set(:@sdk, mock_sdk(block_hash))

    command.execute(output: output)

    expect(output.string).to eq("Imported look 31416\n")
  end

  it "executes `import` command successfully with conflicting slug" do
    output = StringIO.new
    file = nil
    options = {}

    command = Gzr::Commands::Look::Import.new(StringIO.new( <<-LOOK
      {
        "id": 198,
        "slug": "dupe",
        "query_id": 90961,
        "title": "New Look",
        "query": {
          "id": 90961,
          "view": "order_items",
          "fields": [
            "orders.created_date",
            "orders.total_profit"
          ],
          "sorts": [
            "orders.created_date desc"
          ],
          "limit": "500",
          "column_limit": "50",
          "total": null,
          "row_total": null,
          "model": "ecommerce"
        },
        "model": {
          "id": "ecommerce",
          "label": "Ecommerce"
        },
        "deleted": false,
        "public": null
      }
    LOOK
    ), 1, options)

    block_hash = {:create_look =>
      Proc.new do |req|
        expect(req).not_to include(:deleted => true)
        expect(req).to include(:space_id => 1)
        expect(req).not_to include(:folder_id)
        expect(req).not_to include(:slug)
      end
    }
    command.instance_variable_set(:@sdk, mock_sdk(block_hash))

    command.execute(output: output)

    expect(output.string).to end_with("Imported look 31416\n")
  end

  it "executes `import` command and gets exception with conflicting name" do
    output = StringIO.new
    file = nil
    options = {}

    command = Gzr::Commands::Look::Import.new(StringIO.new( <<-LOOK
      {
        "id": 198,
        "query_id": 90961,
        "title": "Daily Profit",
        "query": {
          "id": 90961,
          "view": "order_items",
          "fields": [
            "orders.created_date",
            "orders.total_profit"
          ],
          "sorts": [
            "orders.created_date desc"
          ],
          "limit": "500",
          "column_limit": "50",
          "total": null,
          "row_total": null,
          "model": "ecommerce"
        },
        "model": {
          "id": "ecommerce",
          "label": "Ecommerce"
        },
        "deleted": false,
        "public": null
      }
    LOOK
    ), 1, options)

    command.instance_variable_set(:@sdk, mock_sdk)

    expect { command.execute(output: output) }.to raise_error(/Use --force/)
  end

  it "executes `import` command with conflicting name and succeeds with force flag" do
    output = StringIO.new
    file = nil
    options = {:force=>true}

    command = Gzr::Commands::Look::Import.new(StringIO.new( <<-LOOK
      {
        "id": 198,
        "query_id": 90961,
        "title": "Daily Profit",
        "space_id": "1",
        "query": {
          "id": 90961,
          "view": "order_items",
          "fields": [
            "orders.created_date",
            "orders.total_profit"
          ],
          "sorts": [
            "orders.created_date desc"
          ],
          "limit": "500",
          "column_limit": "50",
          "total": null,
          "row_total": null,
          "model": "ecommerce"
        },
        "model": {
          "id": "ecommerce",
          "label": "Ecommerce"
        },
        "deleted": false,
        "public": null
      }
    LOOK
    ), 1, options)

    block_hash = {:update_look =>
      Proc.new do |i,req|
        expect(i).to eq(31415)
        expect(req).not_to include(:deleted => true)
        expect(req).not_to include(:folder_id)
        expect(req).not_to include(:slug)
      end
    }
    command.instance_variable_set(:@sdk, mock_sdk(block_hash))

    command.execute(output: output)

    expect(output.string).to end_with("Imported look 31415\n")
  end
end
