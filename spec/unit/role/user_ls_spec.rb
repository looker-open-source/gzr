require 'gzr/commands/role/user_ls'

RSpec.describe Gzr::Commands::Role::UserLs do
  it "executes `role user_ls` command successfully" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Role::UserLs.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
