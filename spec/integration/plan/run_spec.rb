RSpec.describe "`gzr plan runit` command", type: :cli do
  it "executes `gzr plan help runit` command successfully" do
    output = `gzr plan help runit`
    expected_output = <<-OUT
Usage:
  gzr plan runit PLAN_ID

Options:
  -h, [--help], [--no-help]  # Display usage information

Execute a saved plan immediately
    OUT

    expect(output).to eq(expected_output)
  end
end
