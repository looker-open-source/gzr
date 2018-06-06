RSpec.describe "`gzr plan enable` command", type: :cli do
  it "executes `gzr plan help enable` command successfully" do
    output = `gzr plan help enable`
    expected_output = <<-OUT
Usage:
  gzr plan enable PLAN_ID

Options:
  -h, [--help], [--no-help]  # Display usage information

Enable the specified plan
    OUT

    expect(output).to eq(expected_output)
  end
end
