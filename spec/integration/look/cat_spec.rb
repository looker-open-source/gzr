RSpec.describe "`lkr look cat` command", type: :cli do
  it "executes `look cat --help` command successfully" do
    output = `lkr look cat --help`
    expect(output).to eq <<-OUT
Usage:
  lkr look cat LOOK_ID

Options:
  -h, [--help], [--no-help]  # Display usage information
      [--dir=DIR]            # Directory to store output file

Output the JSON representation of a look to the screen or a file
    OUT
  end
end
