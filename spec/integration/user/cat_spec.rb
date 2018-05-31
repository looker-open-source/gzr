RSpec.describe "`gzr user cat` command", type: :cli do
  it "executes `gzr user help cat` command successfully" do
    output = `gzr user help cat`
    expected_output = <<-OUT
Usage:
  gzr user cat USER_ID

Options:
  -h, [--help], [--no-help]  # Display usage information
      [--fields=FIELDS]      # Fields to display
      [--dir=DIR]            # Directory to store output file

Output json information about a user to screen or file
    OUT

    expect(output).to eq(expected_output)
  end
end
