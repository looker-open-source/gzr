require 'gzr/commands/role/ls'

RSpec.describe Gzr::Commands::Role::Ls do
  it "executes `role ls` command successfully" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Role::Ls.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
