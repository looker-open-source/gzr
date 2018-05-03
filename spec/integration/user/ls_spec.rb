RSpec.describe "`lkr user ls` command", type: :cli do
  it "executes `user ls --help` command successfully" do
    output = `lkr user ls --help`
    expect(output).to eq <<-OUT
Usage:
  lkr ls

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT
  end
end
