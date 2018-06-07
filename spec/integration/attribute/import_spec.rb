RSpec.describe "`gzr attribute import` command", type: :cli do
  it "executes `gzr attribute help import` command successfully" do
    output = `gzr attribute help import`
    expected_output = <<-OUT
Usage:
  gzr import

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
