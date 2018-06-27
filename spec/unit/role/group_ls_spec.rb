require 'gzr/commands/role/group_ls'

RSpec.describe Gzr::Commands::Role::GroupLs do
  it "executes `role group_ls` command successfully" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Role::GroupLs.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
