require 'gzr/commands/role/user_add'

RSpec.describe Gzr::Commands::Role::UserAdd do
  it "executes `role user_add` command successfully" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Role::UserAdd.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
