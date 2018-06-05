require 'gzr/commands/plan/enable'

RSpec.describe Gzr::Commands::Plan::Enable do
  it "executes `plan enable` command successfully" do
    require 'sawyer'
    plan_response_doc = {
      :id=>1
    }
    mock_plan_response = double(Sawyer::Resource, plan_response_doc)
    allow(mock_plan_response).to receive(:to_attrs).and_return(plan_response_doc)

    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:authenticated?) { true }
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:update_scheduled_plan) do |plan_id,req|
      return mock_plan_response
    end
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Plan::Enable.new(1,options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq("Enabled plan 1\n")
  end
end
