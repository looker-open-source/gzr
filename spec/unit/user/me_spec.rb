require 'lkr/commands/user/me'

RSpec.describe Lkr::Commands::User::Me do
  it "executes `me` command successfully" do
    output = StringIO.new
    options = {}
    command = Lkr::Commands::User::Me.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
