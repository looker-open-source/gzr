RSpec.describe "`lkr space cat` command", type: :cli do
  it "executes `space cat --help` command successfully" do
    output = `lkr space cat --help`
    expect(output).to eq <<-OUT
Usage:
  lkr cat

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT
  end
end
