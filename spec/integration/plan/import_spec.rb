RSpec.describe "`gzr plan import` command", type: :cli do
  it "executes `gzr plan help import` command successfully" do
    output = `gzr plan help import`
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
