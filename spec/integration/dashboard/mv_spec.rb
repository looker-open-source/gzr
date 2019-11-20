RSpec.describe "`gzr dashboard mv` command", type: :cli do
  it "executes `gzr dashboard help mv` command successfully" do
    output = `gzr dashboard help mv`
    expected_output = <<-OUT
Usage:
  gzr dashboard mv DASHBOARD_ID TARGET_SPACE_ID

Options:
  -h, [--help], [--no-help]  # Display usage information
      [--force]              # Overwrite a dashboard with the same name in the target space

Move a dashboard to the given space
    OUT

    expect(output).to eq(expected_output)
  end
end
