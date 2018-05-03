require 'lkr/commands/space/export'

RSpec.describe Lkr::Commands::Space::Export do
  it "executes `export` command successfully" do
    output = StringIO.new
    options = {}
    command = Lkr::Commands::Space::Export.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
