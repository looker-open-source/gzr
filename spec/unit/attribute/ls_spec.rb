require 'gzr/commands/attribute/ls'

RSpec.describe Gzr::Commands::Attribute::Ls do
  it "executes `attribute ls` command successfully" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Attribute::Ls.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
