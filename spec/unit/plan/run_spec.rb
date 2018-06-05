require 'gzr/commands/plan/run'

RSpec.describe Gzr::Commands::Plan::Run do
  it "executes `plan run` command successfully" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Plan::Run.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
