RSpec.describe "`lkr user me` command", type: :cli do
  it "executes `user me --help` command successfully" do
    output = `lkr user me --help`
    expect(output).to eq <<-OUT
Usage:
  lkr me

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT
  end
end
