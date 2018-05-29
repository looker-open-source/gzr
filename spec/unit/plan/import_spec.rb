require 'gzr/commands/plan/import'

RSpec.describe Gzr::Commands::Plan::Import do
  it "executes `plan import` command successfully" do
    require 'sawyer'
    me_response_doc = {
      :id=>1000,
      :first_name=>"John",
      :last_name=>"Jones",
      :email=>"jjones@example.com"
    }
    mock_me_response = double(Sawyer::Resource, me_response_doc)
    allow(mock_me_response).to receive(:to_attrs).and_return(me_response_doc)

    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:authenticated?) { true }
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:me) do |req|
      return mock_me_response
    end
    mock_sdk.define_singleton_method(:scheduled_plans_for_look) do |look_id,req|
      return []
    end
    mock_sdk.define_singleton_method(:create_scheduled_plan) do |req|
      return
    end
    mock_sdk.define_singleton_method(:operations) do 
      {
        "create_scheduled_plan"=> {
          :info=>{
            :parameters=>[
              {
                :in=>"body",
                :schema=>{ :$ref=>"#/definitions/ScheduledPlan" }
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
    "ScheduledPlan": {
      "properties": {
        "name": {
          "type": "string",
          "description": "Name",
          "x-looker-nullable": true
        },
        "user_id": {
          "type": "integer",
          "format": "int64",
          "description": "User Id which owns this ScheduledPlan",
          "x-looker-nullable": true
        },
        "run_as_recipient": {
          "type": "boolean",
          "description": "Whether schedule is ran as recipient (only applicable for email recipients)",
          "x-looker-nullable": false
        },
        "enabled": {
          "type": "boolean",
          "description": "Whether the ScheduledPlan is enabled",
          "x-looker-nullable": false
        },
        "look_id": {
          "type": "integer",
          "format": "int64",
          "description": "Id of a look",
          "x-looker-nullable": true
        },
        "dashboard_id": {
          "type": "integer",
          "format": "int64",
          "description": "Id of a dashboard",
          "x-looker-nullable": true
        },
        "lookml_dashboard_id": {
          "type": "string",
          "description": "Id of a LookML dashboard",
          "x-looker-nullable": true
        },
        "filters_string": {
          "type": "string",
          "description": "Query string to run look or dashboard with",
          "x-looker-nullable": true
        },
        "require_results": {
          "type": "boolean",
          "description": "Delivery should occur if running the dashboard or look returns results",
          "x-looker-nullable": false
        },
        "require_no_results": {
          "type": "boolean",
          "description": "Delivery should occur if the dashboard look does not return results",
          "x-looker-nullable": false
        },
        "require_change": {
          "type": "boolean",
          "description": "Delivery should occur if data have changed since the last run",
          "x-looker-nullable": false
        },
        "send_all_results": {
          "type": "boolean",
          "description": "Will run an unlimited query and send all results.",
          "x-looker-nullable": false
        },
        "crontab": {
          "type": "string",
          "description": "Vixie-Style crontab specification when to run",
          "x-looker-nullable": true
        },
        "datagroup": {
          "type": "string",
          "description": "Name of a datagroup; if specified will run when datagroup triggered (can't be used with cron string)",
          "x-looker-nullable": true
        },
        "timezone": {
          "type": "string",
          "description": "Timezone for interpreting the specified crontab (default is Looker instance timezone)",
          "x-looker-nullable": true
        },
        "query_id": {
          "type": "string",
          "description": "Query id",
          "x-looker-nullable": true
        },
        "run_once": {
          "type": "boolean",
          "description": "Whether the plan in question should only be run once (usually for testing)",
          "x-looker-nullable": false
        },
        "include_links": {
          "type": "boolean",
          "description": "Whether links back to Looker should be included in this ScheduledPlan",
          "x-looker-nullable": false
        }
      },
      "x-looker-status": "beta"
    }
  }
}
      SWAGGER
    end

    output = StringIO.new
    file = nil
    options = {}

    command = Gzr::Commands::Plan::Import.new(StringIO.new( <<-PLAN
{
  "name": "foo",
  "run_as_recipient": null,
  "enabled": true,
  "look_id": 1000,
  "dashboard_id": null,
  "lookml_dashboard_id": null,
  "filters_string": null,
  "dashboard_filters": null,
  "require_results": false,
  "require_no_results": false,
  "require_change": false,
  "send_all_results": false,
  "crontab": "*/5 * * * *",
  "datagroup": null,
  "timezone": "America/Los_Angeles",
  "query_id": null,
  "scheduled_plan_destination": [
  ],
  "run_once": false,
  "include_links": false
}
    PLAN
    ), "LOOK", 1, options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq("")
  end
end
