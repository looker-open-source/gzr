RSpec.describe "`gzr role cat` command", type: :cli do
  it "executes `gzr role help cat` command successfully" do
    output = `gzr role help cat`
    expected_output = <<-OUT
Usage:
  gzr role cat ROLE_ID

Options:
  -h, [--help], [--no-help]  # Display usage information
      [--dir=DIR]            # Directory to get output file

Output the JSON representation of a role to the screen or a file
    OUT

    expect(output).to eq(expected_output)
  end
end
