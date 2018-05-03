RSpec.describe "`lkr space tree` command", type: :cli do
  it "executes `space tree --help` command successfully" do
    output = `lkr space tree --help`
    expect(output).to eq <<-OUT
Usage:
  lkr tree

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT
  end
end
