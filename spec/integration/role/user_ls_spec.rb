RSpec.describe "`gzr role user_ls` command", type: :cli do
  it "executes `gzr role help user_ls` command successfully" do
    output = `gzr role help user_ls`
    expected_output = <<-OUT
Usage:
  gzr role user_ls ROLE_ID

Options:
  -h, [--help], [--no-help]            # Display usage information
      [--fields=FIELDS]                # Fields to display
                                       # Default: id,first_name,last_name,email
      [--plain], [--no-plain]          # print without any extra formatting
      [--csv], [--no-csv]              # output in csv format per RFC4180
      [--all-users], [--no-all-users]  # Show users with this role through a group membership

List the users assigned to a role
    OUT

    expect(output).to eq(expected_output)
  end
end
