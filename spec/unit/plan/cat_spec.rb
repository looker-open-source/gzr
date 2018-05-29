require 'gzr/commands/plan/cat'

RSpec.describe Gzr::Commands::Plan::Cat do
  it "executes `plan cat` command successfully" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Plan::Cat.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
