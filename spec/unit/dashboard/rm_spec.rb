require 'lkr/commands/dashboard/rm'

RSpec.describe Lkr::Commands::Dashboard::Rm do
  it "executes `rm` command successfully" do
    output = StringIO.new
    options = {}
    command = Lkr::Commands::Dashboard::Rm.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
