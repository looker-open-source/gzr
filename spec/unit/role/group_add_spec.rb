require 'gzr/commands/role/group_add'

RSpec.describe Gzr::Commands::Role::GroupAdd do
  it "executes `role group_add` command successfully" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Role::GroupAdd.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
