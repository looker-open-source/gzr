RSpec.describe "`gzr plan disable` command", type: :cli do
  it "executes `gzr plan help disable` command successfully" do
    output = `gzr plan help disable`
    expected_output = <<-OUT
Usage:
  gzr plan disable PLAN_ID

Options:
  -h, [--help], [--no-help]  # Display usage information

Disable the specified plan
    OUT

    expect(output).to eq(expected_output)
  end
end
