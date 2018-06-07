require 'gzr/commands/attribute/create'

RSpec.describe Gzr::Commands::Attribute::Create do
  it "executes `attribute create` command successfully" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Attribute::Create.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
