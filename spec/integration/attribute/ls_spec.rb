RSpec.describe "`gzr attribute ls` command", type: :cli do
  it "executes `gzr attribute help ls` command successfully" do
    output = `gzr attribute help ls`
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
