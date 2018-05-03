require 'lkr/commands/look/cat'

RSpec.describe Lkr::Commands::Look::Cat do
  it "executes `cat` command successfully" do
    output = StringIO.new
    options = {}
    command = Lkr::Commands::Look::Cat.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
