RSpec.describe "`lkr group member_users` command", type: :cli do
  it "executes `group member_users --help` command successfully" do
    output = `lkr group member_users --help`
    expect(output).to eq <<-OUT
Usage:
  lkr group member_users GROUP_ID

Options:
  -h, [--help], [--no-help]    # Display usage information
      [--fields=FIELDS]        # Fields to display
                               # Default: id,email,last_name,first_name,personal_space_id,home_space_id
      [--plain], [--no-plain]  # print without any extra formatting
      [--csv], [--no-csv]      # output in csv format per RFC4180

List the users that are members of the given group
    OUT
  end
end
