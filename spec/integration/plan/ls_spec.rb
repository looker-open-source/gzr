RSpec.describe "`gzr plans ls` command", type: :cli do
  it "executes `gzr plans help ls` command successfully" do
    output = `gzr plans help ls`
    expected_output = <<-OUT
Usage:
  gzr ls

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
