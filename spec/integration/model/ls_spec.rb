RSpec.describe "`lkr model ls` command", type: :cli do
  it "executes `model ls --help` command successfully" do
    output = `lkr model ls --help`
    expect(output).to eq <<-OUT
Usage:
  lkr ls

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT
  end
end
