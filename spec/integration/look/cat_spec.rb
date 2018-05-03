RSpec.describe "`lkr look cat` command", type: :cli do
  it "executes `look cat --help` command successfully" do
    output = `lkr look cat --help`
    expect(output).to eq <<-OUT
Usage:
  lkr cat

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT
  end
end
