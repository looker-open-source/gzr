RSpec.describe "`gzr dashboard rm` command", type: :cli do
  it "executes `dashboard rm --help` command successfully" do
    output = `gzr dashboard rm --help`
    expect(output).to eq <<-OUT
Usage:
  gzr dashboard rm DASHBOARD_ID

Options:
  -h, [--help], [--no-help]  # Display usage information

Remove or delete the given dashboard
    OUT
  end
end
