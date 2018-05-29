require 'gzr/commands/plan/import'

RSpec.describe Gzr::Commands::Plan::Import do
  it "executes `plan import` command successfully" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Plan::Import.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
