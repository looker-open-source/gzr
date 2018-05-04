RSpec.describe "`lkr space cat` command", type: :cli do
  it "executes `space cat --help` command successfully" do
    output = `lkr space cat --help`
    expect(output).to eq <<-OUT
Usage:
  lkr space cat SPACE_ID

Options:
  -h, [--help], [--no-help]  # Display usage information
      [--dir=DIR]            # Directory to get output file

Output the JSON representation of a space to the screen or a file
    OUT
  end
end
