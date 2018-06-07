require 'gzr/commands/attribute/set_group_values'

RSpec.describe Gzr::Commands::Attribute::SetGroupValues do
  it "executes `attribute set_group_values` command successfully" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Attribute::SetGroupValues.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
