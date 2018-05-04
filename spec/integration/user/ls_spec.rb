RSpec.describe "`lkr user ls` command", type: :cli do
  it "executes `user ls --help` command successfully" do
    output = `lkr user ls --help`
    expect(output).to eq <<-OUT
Usage:
  lkr user ls

Options:
  -h, [--help], [--no-help]    # Display usage information
      [--fields=FIELDS]        # Fields to display
                               # Default: id,email,last_name,first_name
      [--plain], [--no-plain]  # print without any extra formatting

list all users
    OUT
  end
end
