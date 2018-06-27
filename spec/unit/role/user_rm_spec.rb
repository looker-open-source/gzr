require 'gzr/commands/role/user_rm'

RSpec.describe Gzr::Commands::Role::UserRm do
  it "executes `role user_rm` command successfully" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Role::UserRm.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
