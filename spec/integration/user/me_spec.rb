RSpec.describe "`lkr user me` command", type: :cli do
  it "executes `user me --help` command successfully" do
    output = `lkr user me --help`
    expect(output).to eq <<-OUT
Usage:
  lkr user me

Options:
  -h, [--help], [--no-help]    # Display usage information
      [--fields=FIELDS]        # Fields to display
                               # Default: id,email,last_name,first_name
      [--plain], [--no-plain]  # print without any extra formatting

Show information for the current user
    OUT
  end
end
