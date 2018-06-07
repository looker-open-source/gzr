RSpec.describe "`gzr attribute rm` command", type: :cli do
  it "executes `gzr attribute help rm` command successfully" do
    output = `gzr attribute help rm`
    expected_output = <<-OUT
Usage:
  gzr rm

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
