RSpec.describe "`gzr attribute set_group_values` command", type: :cli do
  it "executes `gzr attribute help set_group_values` command successfully" do
    output = `gzr attribute help set_group_values`
    expected_output = <<-OUT
Usage:
  gzr set_group_values

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
