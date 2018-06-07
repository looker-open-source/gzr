require 'gzr/commands/user/enable'

RSpec.describe Gzr::Commands::User::Enable do
  it "executes `user enable` command successfully" do
    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:update_user) do |user_id,body|
      return
    end

    output = StringIO.new
    options = {}
    command = Gzr::Commands::User::Enable.new(1,options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq("")
  end
end
