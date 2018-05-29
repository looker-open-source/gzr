RSpec.describe "`gzr plan cat` command", type: :cli do
  it "executes `gzr plan help cat` command successfully" do
    output = `gzr plan help cat`
    expected_output = <<-OUT
Usage:
  gzr plan cat PLAN_ID

Options:
  -h, [--help], [--no-help]  # Display usage information
      [--dir=DIR]            # Directory to get output file

Output the JSON representation of a scheduled plan to the screen or a file
    OUT

    expect(output).to eq(expected_output)
  end
end
