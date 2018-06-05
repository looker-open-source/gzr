RSpec.describe "`gzr plan import` command", type: :cli do
  it "executes `gzr plan help import` command successfully" do
    output = `gzr plan help import`
    expected_output = <<-OUT
Usage:
  gzr plan import PLAN_FILE OBJ_TYPE OBJ_ID

Options:
  -h, [--help], [--no-help]        # Display usage information
      [--plain], [--no-plain]      # Provide minimal response information
      [--enable], [--no-enable]    # Enable the plan on import
      [--disable], [--no-disable]  # Disable the plan on import

Import a plan from a file
    OUT

    expect(output).to eq(expected_output)
  end
end
