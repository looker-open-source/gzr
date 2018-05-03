RSpec.describe "`lkr space ls` command", type: :cli do
  it "executes `space ls --help` command successfully" do
    output = `lkr space ls --help`
    expect(output).to eq <<-OUT
Usage:
  lkr ls

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT
  end
end
