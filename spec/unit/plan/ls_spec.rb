require 'gzr/commands/plans/ls'

RSpec.describe Gzr::Commands::Plans::Ls do
  it "executes `plans ls` command successfully" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Plans::Ls.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
