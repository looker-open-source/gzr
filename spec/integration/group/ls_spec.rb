RSpec.describe "`gzr group ls` command", type: :cli do
  it "executes `group ls --help` command successfully" do
    output = `gzr group ls --help`
    expect(output).to eq <<-OUT
Usage:
  gzr group ls

Options:
  -h, [--help], [--no-help]    # Display usage information
      [--fields=FIELDS]        # Fields to display
                               # Default: id,name,user_count,contains_current_user,externally_managed,external_group_id
      [--plain], [--no-plain]  # print without any extra formatting
      [--csv], [--no-csv]      # output in csv format per RFC4180

List the groups that are defined on this server
    OUT
  end
end
