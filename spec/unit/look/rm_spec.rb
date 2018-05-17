require 'lkr/commands/look/rm'

RSpec.describe Lkr::Commands::Look::Rm do
  it "executes `rm` command successfully" do
    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:delete_look) do |id|
      return 
    end

    output = StringIO.new
    look_id = nil
    options = {}
    command = Lkr::Commands::Look::Rm.new(look_id, options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq("")
  end
end
