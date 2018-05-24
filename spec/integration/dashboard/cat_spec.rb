RSpec.describe "`gzr dashboard cat` command", type: :cli do
  it "executes `dashboard cat --help` command successfully" do
    output = `gzr dashboard cat --help`
    expect(output).to eq <<-OUT
Usage:
  gzr dashboard cat DASHBOARD_ID

Options:
  -h, [--help], [--no-help]  # Display usage information
      [--dir=DIR]            # Directory to store output file

Output the JSON representation of a dashboard to the screen or a file
    OUT
  end
end
