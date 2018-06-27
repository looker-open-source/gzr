require 'gzr/commands/role/group_rm'

RSpec.describe Gzr::Commands::Role::GroupRm do
  it "executes `role group_rm` command successfully" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Role::GroupRm.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
