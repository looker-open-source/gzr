require 'gzr/commands/role/rm'

RSpec.describe Gzr::Commands::Role::Rm do
  it "executes `role rm` command successfully" do
    require 'sawyer'
    mock_sdk = Object.new
    allow(mock_sdk).to receive(:logout)
    allow(mock_sdk).to receive(:delete_role) do |role_id,body|
      nil
    end
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Role::Rm.new(1,options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq("")
  end
end
