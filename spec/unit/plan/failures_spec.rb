require 'gzr/commands/plan/failures'

RSpec.describe Gzr::Commands::Plan::Failures do
  it "executes `plan failures` command successfully" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Plan::Failures.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
