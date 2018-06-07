require 'gzr/commands/attribute/rm'

RSpec.describe Gzr::Commands::Attribute::Rm do
  it "executes `attribute rm` command successfully" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Attribute::Rm.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
