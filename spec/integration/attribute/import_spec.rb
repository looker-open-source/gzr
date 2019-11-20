RSpec.describe "`gzr attribute import` command", type: :cli do
  it "executes `gzr attribute help import` command successfully" do
    output = `gzr attribute help import`
    expected_output = <<-OUT
Usage:
  gzr attribute import FILE

Options:
  -h, [--help], [--no-help]    # Display usage information
      [--plain], [--no-plain]  # Provide minimal response information
      [--force]                # If the user attribute already exists, modify it

Import a user attribute from a file
    OUT

    expect(output).to eq(expected_output)
  end
end
