require 'lkr/commands/dashboard/rm'

RSpec.describe Lkr::Commands::Dashboard::Rm do
  it "executes `rm` command successfully" do
    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:delete_dashboard) do |id|
      return 
    end

    output = StringIO.new
    options = {}
    command = Lkr::Commands::Dashboard::Rm.new(1, options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq("")
  end
end
