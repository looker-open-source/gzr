RSpec.describe "`lkr dashboard cat` command", type: :cli do
  it "executes `dashboard cat --help` command successfully" do
    output = `lkr dashboard cat --help`
    expect(output).to eq <<-OUT
Usage:
  lkr dashboard cat DASHBOARD_ID

Options:
  -h, [--help], [--no-help]  # Display usage information
      [--dir=DIR]            # Directory to store output file

Output the JSON representation of a dashboard to the screen or a file
    OUT
  end
end
