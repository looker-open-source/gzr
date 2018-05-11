RSpec.describe "`lkr dashboard import` command", type: :cli do
  it "executes `dashboard import --help` command successfully" do
    output = `lkr dashboard import --help`
    expect(output).to eq <<-OUT
Usage:
  lkr import

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT
  end
end
