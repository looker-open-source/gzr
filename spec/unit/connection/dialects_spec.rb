require 'lkr/commands/connection/dialects'

RSpec.describe Lkr::Commands::Connection::Dialects do
  it "executes `dialects` command successfully" do
    output = StringIO.new
    options = {}
    command = Lkr::Commands::Connection::Dialects.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
