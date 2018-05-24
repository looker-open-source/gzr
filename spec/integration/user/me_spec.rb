RSpec.describe "`gzr user me` command", type: :cli do
  it "executes `user me --help` command successfully" do
    output = `gzr user me --help`
    expect(output).to eq <<-OUT
Usage:
  gzr user me

Options:
  -h, [--help], [--no-help]    # Display usage information
      [--fields=FIELDS]        # Fields to display
                               # Default: id,email,last_name,first_name,personal_space_id,home_space_id
      [--plain], [--no-plain]  # print without any extra formatting
      [--csv], [--no-csv]      # output in csv format per RFC4180

Show information for the current user
    OUT
  end
end
