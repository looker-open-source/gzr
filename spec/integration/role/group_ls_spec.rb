RSpec.describe "`gzr role group_ls` command", type: :cli do
  it "executes `gzr role help group_ls` command successfully" do
    output = `gzr role help group_ls`
    expected_output = <<-OUT
Usage:
  gzr role group_ls ROLE_ID

Options:
  -h, [--help], [--no-help]    # Display usage information
      [--fields=FIELDS]        # Fields to display
                               # Default: id,name,external_group_id
      [--plain], [--no-plain]  # print without any extra formatting
      [--csv], [--no-csv]      # output in csv format per RFC4180

List the groups assigned to a role
    OUT

    expect(output).to eq(expected_output)
  end
end
