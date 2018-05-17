require 'lkr/commands/space/create'

RSpec.describe Lkr::Commands::Space::Create do
  it "executes `create` command successfully" do
    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:create_space) do |req|
      return 
    end

    output = StringIO.new
    options = {}
    command = Lkr::Commands::Space::Create.new("new space", 1, options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq("")
  end
end
