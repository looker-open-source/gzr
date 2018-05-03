require 'lkr/commands/space/cat'

RSpec.describe Lkr::Commands::Space::Cat do
  it "executes `cat` command successfully" do
    output = StringIO.new
    options = {}
    command = Lkr::Commands::Space::Cat.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
