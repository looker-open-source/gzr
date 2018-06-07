RSpec.describe "`gzr attribute create` command", type: :cli do
  it "executes `gzr attribute help create` command successfully" do
    output = `gzr attribute help create`
    expected_output = <<-OUT
Usage:
  gzr create

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
