RSpec.describe "`lkr user ls` command", type: :cli do
  it "executes `user ls --help` command successfully" do
    output = `lkr user ls --help`
    expect(output).to eq <<-OUT
Usage:
  lkr user ls

Options:
  -h, [--help], [--no-help]    # Display usage information
      [--fields=FIELDS]        # Fields to display
                               # Default: id,email,last_name,first_name,personal_space_id,home_space_id
      [--plain], [--no-plain]  # print without any extra formatting
      [--csv], [--no-csv]      # output in csv format per RFC4180

list all users
    OUT
  end
end
