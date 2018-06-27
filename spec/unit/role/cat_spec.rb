require 'gzr/commands/role/cat'

RSpec.describe Gzr::Commands::Role::Cat do
  it "executes `role cat` command successfully" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Role::Cat.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
