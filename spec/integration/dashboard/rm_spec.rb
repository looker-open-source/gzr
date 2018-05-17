RSpec.describe "`lkr dashboard rm` command", type: :cli do
  it "executes `dashboard rm --help` command successfully" do
    output = `lkr dashboard rm --help`
    expect(output).to eq <<-OUT
Usage:
  lkr dashboard rm DASHBOARD_ID

Options:
  -h, [--help], [--no-help]  # Display usage information

Remove or delete the given dashboard
    OUT
  end
end
