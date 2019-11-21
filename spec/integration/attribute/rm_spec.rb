RSpec.describe "`gzr attribute rm` command", type: :cli do
  it "executes `gzr attribute help rm` command successfully" do
    output = `gzr attribute help rm`
    expected_output = <<-OUT
Usage:
  gzr attribute rm ATTR_ID|ATTR_NAME

Options:
  -h, [--help], [--no-help]    # Display usage information
      [--plain], [--no-plain]  # Provide minimal response information

Delete a user attribute
    OUT

    expect(output).to eq(expected_output)
  end
end
