RSpec.describe "`lkr space top` command", type: :cli do
  it "executes `space top --help` command successfully" do
    output = `lkr space top --help`
    expect(output).to eq <<-OUT
Usage:
  lkr space top

Options:
  -h, [--help], [--no-help]  # Display usage information

Retrieve the top level (or root) spaces
    OUT
  end
end
