require 'gzr/commands/plan/rm'

RSpec.describe Gzr::Commands::Plan::Rm do
  it "executes `plan rm` command successfully" do
    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:delete_scheduled_plan) do |plan_id|
      return 
    end

    output = StringIO.new
    options = {}
    command = Gzr::Commands::Plan::Rm.new(1,options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq("")
  end
end
