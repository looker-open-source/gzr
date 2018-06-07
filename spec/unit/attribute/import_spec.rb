require 'gzr/commands/attribute/import'

RSpec.describe Gzr::Commands::Attribute::Import do
  it "executes `attribute import` command successfully" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Attribute::Import.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
