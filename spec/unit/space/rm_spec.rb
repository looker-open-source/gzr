require 'lkr/commands/space/rm'

RSpec.describe Lkr::Commands::Space::Rm do
  it "executes `rm` command successfully" do
    output = StringIO.new
    options = {}
    command = Lkr::Commands::Space::Rm.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
