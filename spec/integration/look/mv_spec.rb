RSpec.describe "`gzr look mv` command", type: :cli do
  it "executes `gzr look help mv` command successfully" do
    output = `gzr look help mv`
    expected_output = <<-OUT
Usage:
  gzr look mv LOOK_ID TARGET_SPACE_ID

Options:
  -h, [--help], [--no-help]  # Display usage information
      [--force]              # Overwrite a look with the same name in the target space

Move a look to the given space
    OUT

    expect(output).to eq(expected_output)
  end
end
