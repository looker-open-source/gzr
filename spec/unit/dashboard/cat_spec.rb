require 'lkr/commands/dashboard/cat'

RSpec.describe Lkr::Commands::Dashboard::Cat do
  it "executes `cat` command successfully" do
    output = StringIO.new
    options = {}
    command = Lkr::Commands::Dashboard::Cat.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
