require 'lkr/commands/space/create'

RSpec.describe Lkr::Commands::Space::Create do
  it "executes `create` command successfully" do
    output = StringIO.new
    name,parent_space = nil
    options = {}
    command = Lkr::Commands::Space::Create.new(name,parent_space, options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
