require 'gzr/commands/plan/run'

RSpec.describe Gzr::Commands::Plan::RunIt do
  it "executes `plan run` command successfully" do
    require 'sawyer'
    mock_response = double(Sawyer::Resource, { :id=>1, :name=>"foo" })
    allow(mock_response).to receive(:to_attrs).and_return({ :id=>1, :name=>"foo" })
    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:scheduled_plan) do |plan_id, body|
      return mock_response
    end
    mock_sdk.define_singleton_method(:scheduled_plan_run_once) do |body|
      return
    end

    output = StringIO.new
    options = {}
    command = Gzr::Commands::Plan::RunIt.new(1,options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq("Executed plan 1\n")
  end
end
