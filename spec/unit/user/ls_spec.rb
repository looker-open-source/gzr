require 'lkr/commands/user/ls'

RSpec.describe Lkr::Commands::User::Ls do
  it "executes `ls` command successfully" do
    output = StringIO.new
    options = {}
    command = Lkr::Commands::User::Ls.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
