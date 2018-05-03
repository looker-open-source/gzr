RSpec.describe "`lkr dashboard cat` command", type: :cli do
  it "executes `dashboard cat --help` command successfully" do
    output = `lkr dashboard cat --help`
    expect(output).to eq <<-OUT
Usage:
  lkr cat

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT
  end
end
