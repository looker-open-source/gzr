require 'lkr/commands/space/ls'

RSpec.describe Lkr::Commands::Space::Ls do
  it "executes `ls` command successfully" do
    output = StringIO.new
    options = {}
    command = Lkr::Commands::Space::Ls.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
