RSpec.describe "`gzr plan rm` command", type: :cli do
  it "executes `gzr plan help rm` command successfully" do
    output = `gzr plan help rm`
    expected_output = <<-OUT
Usage:
  gzr plan rm PLAN_ID

Options:
  -h, [--help], [--no-help]  # Display usage information

Delete a scheduled plan
    OUT

    expect(output).to eq(expected_output)
  end
end
