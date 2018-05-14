RSpec.describe "`lkr space rm` command", type: :cli do
  it "executes `space rm --help` command successfully" do
    output = `lkr space rm --help`
    expect(output).to eq <<-OUT
Usage:
  lkr rm

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT
  end
end
