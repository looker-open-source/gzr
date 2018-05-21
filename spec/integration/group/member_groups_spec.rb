RSpec.describe "`lkr group member_groups` command", type: :cli do
  it "executes `group member_groups --help` command successfully" do
    output = `lkr group member_groups --help`
    expect(output).to eq <<-OUT
Usage:
  lkr group member_groups GROUP_ID

Options:
  -h, [--help], [--no-help]    # Display usage information
      [--fields=FIELDS]        # Fields to display
                               # Default: id,name,user_count,contains_current_user,externally_managed,external_group_id
      [--plain], [--no-plain]  # print without any extra formatting
      [--csv], [--no-csv]      # output in csv format per RFC4180

List the groups that are members of the given group
    OUT
  end
end
