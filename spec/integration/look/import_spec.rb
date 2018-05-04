RSpec.describe "`lkr look import` command", type: :cli do
  it "executes `look import --help` command successfully" do
    output = `lkr look import --help`
    expect(output).to eq <<-OUT
Usage:
  lkr import FILE

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT
  end
end
