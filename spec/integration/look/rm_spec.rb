RSpec.describe "`lkr look rm` command", type: :cli do
  it "executes `look rm --help` command successfully" do
    output = `lkr look rm --help`
    expect(output).to eq <<-OUT
Usage:
  lkr rm LOOK_ID

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT
  end
end
