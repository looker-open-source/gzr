RSpec.describe "`lkr connection ls` command", type: :cli do
  it "executes `connection ls --help` command successfully" do
    output = `lkr connection ls --help`
    expect(output).to eq <<-OUT
Usage:
  lkr ls

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT
  end
end
