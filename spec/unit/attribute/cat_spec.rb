require 'gzr/commands/attribute/cat'

RSpec.describe Gzr::Commands::Attribute::Cat do
  it "executes `attribute cat` command successfully" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Attribute::Cat.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
