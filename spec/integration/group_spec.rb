RSpec.describe "`lkr group` command", type: :cli do
  it "executes `group --help` command successfully" do
    output = `lkr group --help`
    expect(output).to eq <<-OUT
Commands:
  lkr group help [COMMAND]          # Describe subcommands or one specific subcommand
  lkr group ls                      # List the groups that are defined on this server
  lkr group member_groups GROUP_ID  # List the groups that are members of the given group
  lkr group member_users GROUP_ID   # List the users that are members of the given group

    OUT
  end
end
