require 'gzr/commands/plan/rm'

RSpec.describe Gzr::Commands::Plan::Rm do
  it "executes `plan rm` command successfully" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Plan::Rm.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
