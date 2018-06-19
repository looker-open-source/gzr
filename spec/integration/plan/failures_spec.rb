RSpec.describe "`gzr plan failures` command", type: :cli do
  it "executes `gzr plan help failures` command successfully" do
    output = `gzr plan help failures`
    expected_output = <<-OUT
Usage:
  gzr failures

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
