require 'lkr/commands/look/rm'

RSpec.describe Lkr::Commands::Look::Rm do
  it "executes `rm` command successfully" do
    output = StringIO.new
    look_id = nil
    options = {}
    command = Lkr::Commands::Look::Rm.new(look_id, options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
