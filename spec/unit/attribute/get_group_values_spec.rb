require 'gzr/commands/attribute/get_group_values'

RSpec.describe Gzr::Commands::Attribute::GetGroupValues do
  it "executes `attribute get_group_values` command successfully" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Attribute::GetGroupValues.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
