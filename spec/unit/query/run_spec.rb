require 'gzr/commands/query/run'

RSpec.describe Gzr::Commands::Query::Run do
  it "executes `query run` command successfully" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Query::Run.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
