require 'lkr/commands/model/ls'

RSpec.describe Lkr::Commands::Model::Ls do
  it "executes `ls` command successfully" do
    output = StringIO.new
    options = {}
    command = Lkr::Commands::Model::Ls.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
