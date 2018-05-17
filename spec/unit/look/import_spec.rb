require 'lkr/commands/look/import'

RSpec.describe Lkr::Commands::Look::Import do
  it "executes `import` command successfully" do
    require 'sawyer'
    me_response_doc = { :id=>1000, :first_name=>"John", :last_name=>"Jones", :email=>"jjones@example.com" }
    mock_me_response = double(Sawyer::Resource, me_response_doc)
    allow(mock_me_response).to receive(:to_attrs).and_return(me_response_doc)

    query_response_doc = {
      :id=>555
    }
    mock_query_response = double(Sawyer::Resource, query_response_doc)
    allow(mock_query_response).to receive(:to_attrs).and_return(query_response_doc)

    look_response_doc = {
      :id=>31415,
      :title=>"Daily Profit",
      :description=>"Total profit by day for the last 100 days",
      :query_id=>555,
      :user_id=>1000,
      :space_id=>1
    }
    mock_look_response = double(Sawyer::Resource, look_response_doc)
    allow(mock_look_response).to receive(:to_attrs).and_return(look_response_doc)

    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:authenticated?) { true }
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:me) do |req|
      return mock_me_response
    end
    mock_sdk.define_singleton_method(:search_looks) do |req|
      return []
    end
    mock_sdk.define_singleton_method(:operations) do 
      {
        "create_query"=> {
          :info=>{
            :parameters=>[
              {
                :in=>"body",
                :schema=>{ :$ref=>"#/definitions/Query" }
              }
            ]
          }
        },
        "create_look"=>{
          :info=>{
            :parameters=>[
              {
                :in=>"body",
                :schema=>{ :$ref=>"#/definitions/Look" }
              }
            ]
          }
        }
      }
    end
    mock_sdk.define_singleton_method(:swagger) do 
      JSON.parse <<-SWAGGER, {:symbolize_names => true}
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
    end

    mock_sdk.define_singleton_method(:create_query) do |req|
      #$stderr.puts JSON.pretty_generate req
      return mock_query_response
    end
    mock_sdk.define_singleton_method(:create_look) do |req|
      $stderr.puts JSON.pretty_generate req
      return mock_look_response
    end
    output = StringIO.new
    file = nil
    options = {}

    command = Lkr::Commands::Look::Import.new(StringIO.new( <<-LOOK
{
  "id": 198,
  "content_metadata_id": 1155,
  "view_count": 13,
  "favorite_count": 0,
  "last_accessed_at": "2018-02-05 20:33:54 +0000",
  "user": {
    "id": 696
  },
  "user_id": 696,
  "query_id": 90961,
  "title": "Daily Profit",
  "created_at": "2015-04-09 18:53:26 +0000",
  "updated_at": "2018-04-30 19:38:23 +0000",
  "description": "Total profit by day for the last 100 days",
  "short_url": "/looks/198",
  "space_id": 673,
  "space": {
    "id": 673,
    "creator_id": 696,
    "name": "**Company-Wide**",
    "content_metadata_id": 28,
    "is_personal": false,
    "is_shared_root": false,
    "is_users_root": false,
    "is_personal_descendant": false,
    "is_embed": false,
    "is_embed_shared_root": false,
    "is_embed_users_root": false,
    "external_id": null,
    "is_user_root": false,
    "is_root": false,
    "can": {
      "index": true,
      "show": true,
      "create": true,
      "see_admin_spaces": true,
      "update": true,
      "destroy": true,
      "move_content": true,
      "edit_content": true
    }
  },
  "last_updater_id": 943,
  "deleted_at": null,
  "deleter_id": null,
  "is_run_on_load": true,
  "query": {
    "id": 90961,
    "view": "order_items",
    "fields": [
      "orders.created_date",
      "orders.total_profit"
    ],
    "pivots": null,
    "fill_fields": null,
    "filters": {
      "orders.created_date": "100 days",
      "order_items.date_filter": "true"
    },
    "filter_expression": null,
    "sorts": [
      "orders.created_date desc"
    ],
    "limit": "500",
    "column_limit": "50",
    "total": null,
    "row_total": null,
    "runtime": 0.6258010864257812,
    "vis_config": {
      "type": "looker_line",
      "show_null_points": false,
      "show_y_axis_labels": true,
      "show_y_axis_ticks": true,
      "y_axis_gridlines": true,
      "y_axis_combined": true,
      "stacking": "",
      "show_value_labels": false,
      "x_axis_gridlines": false,
      "show_view_names": true,
      "show_x_axis_label": true,
      "show_x_axis_ticks": true,
      "x_axis_scale": "auto",
      "point_style": "none",
      "interpolation": "linear",
      "discontinuous_nulls": false,
      "x_axis_datetime_tick_count": 10,
      "label_density": 25,
      "legend_position": "center",
      "limit_displayed_rows": false,
      "y_axis_tick_density": "default",
      "y_axis_tick_density_custom": 5,
      "y_axis_scale_mode": "linear",
      "hidden_fields": [

      ],
      "y_axes": [

      ]
    },
    "filter_config": {
      "orders.created_date": [
        {
          "type": "past",
          "values": [
            {
              "constant": "100",
              "unit": "day"
            },
            {
            }
          ],
          "id": 0
        }
      ],
      "order_items.date_filter": [
        {
          "type": "advanced",
          "values": [
            {
              "constant": "true"
            },
            {
            }
          ],
          "id": 0
        }
      ]
    },
    "visible_ui_sections": null,
    "client_id": "1ehnZEi7EIjlGyaIijQh1S",
    "query_timezone": "America/Los_Angeles",
    "has_table_calculations": false,
    "model": "ecommerce",
    "can": {
      "run": true,
      "see_results": true,
      "explore": true,
      "create": true,
      "show": true,
      "cost_estimate": true,
      "index": true,
      "see_lookml": true,
      "see_derived_table_lookml": true,
      "see_sql": true,
      "generate_drill_links": true,
      "download": true,
      "render": true
    }
  },
  "model": {
    "id": "ecommerce",
    "label": "Ecommerce"
  },
  "content_favorite_id": null,
  "last_viewed_at": null,
  "deleted": false,
  "public": null,
  "can": {
    "download": true,
    "index": true,
    "show": true,
    "copy": true,
    "run": true,
    "create": true,
    "explore": true,
    "move": true,
    "update": true,
    "destroy": true,
    "recover": true,
    "update_publicity": true,
    "show_errors": true,
    "find_and_replace": true,
    "schedule": true,
    "render": true
  }
}
    LOOK
    ), 1, options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq("Imported look 31415\n")
  end
end
