require 'gzr/commands/role/rm'

RSpec.describe Gzr::Commands::Role::Rm do
  it "executes `role rm` command successfully" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Role::Rm.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
