require 'lkr/commands/space/tree'

RSpec.describe Lkr::Commands::Space::Tree do
  it "executes `tree` command successfully" do
    output = StringIO.new
    options = {}
    command = Lkr::Commands::Space::Tree.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
