require 'lkr/commands/connection/ls'

RSpec.describe Lkr::Commands::Connection::Ls do
  it "executes `ls` command successfully" do
    output = StringIO.new
    options = {}
    command = Lkr::Commands::Connection::Ls.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
