RSpec.describe "`lkr connection dialects` command", type: :cli do
  it "executes `connection dialects --help` command successfully" do
    output = `lkr connection dialects --help`
    expect(output).to eq <<-OUT
Usage:
  lkr dialects

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT
  end
end
