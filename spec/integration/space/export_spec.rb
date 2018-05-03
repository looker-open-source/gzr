RSpec.describe "`lkr space export` command", type: :cli do
  it "executes `space export --help` command successfully" do
    output = `lkr space export --help`
    expect(output).to eq <<-OUT
Usage:
  lkr export

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT
  end
end
