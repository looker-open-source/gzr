RSpec.describe "`gzr user ls` command", type: :cli do
  it "executes `user ls --help` command successfully" do
    output = `gzr user ls --help`
    expect(output).to eq <<-OUT
Usage:
  gzr user ls

Options:
  -h, [--help], [--no-help]              # Display usage information
      [--fields=FIELDS]                  # Fields to display
                                         # Default: id,email,last_name,first_name,personal_space_id,home_space_id
      [--last-login], [--no-last-login]  # Include the time of the most recent login
      [--plain], [--no-plain]            # print without any extra formatting
      [--csv], [--no-csv]                # output in csv format per RFC4180

list all users
    OUT
  end
end
