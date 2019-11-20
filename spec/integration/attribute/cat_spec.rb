RSpec.describe "`gzr attribute cat` command", type: :cli do
  it "executes `gzr attribute help cat` command successfully" do
    output = `gzr attribute help cat`
    expected_output = <<-OUT
Usage:
  gzr attribute cat ATTR_ID

Options:
  -h, [--help], [--no-help]  # Display usage information
      [--fields=FIELDS]      # Fields to display
      [--dir=DIR]            # Directory to store output file

Output json information about an attribute to screen or file
    OUT

    expect(output).to eq(expected_output)
  end
end
