RSpec.describe "`lkr space top` command", type: :cli do
  it "executes `space top --help` command successfully" do
    output = `lkr space top --help`
    expect(output).to eq <<-OUT
Usage:
  lkr top

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT
  end
end
