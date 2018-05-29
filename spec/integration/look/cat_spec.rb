RSpec.describe "`gzr look cat` command", type: :cli do
  it "executes `look cat --help` command successfully" do
    output = `gzr look cat --help`
    expect(output).to eq <<-OUT
Usage:
  gzr look cat LOOK_ID

Options:
  -h, [--help], [--no-help]    # Display usage information
      [--dir=DIR]              # Directory to store output file
      [--plans], [--no-plans]  # Include scheduled plans

Output the JSON representation of a look to the screen or a file
    OUT
  end
end
