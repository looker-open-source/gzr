RSpec.describe "`gzr query run` command", type: :cli do
  it "executes `gzr query help run` command successfully" do
    output = `gzr query help run`
    expected_output = <<-OUT
Usage:
  gzr run

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
