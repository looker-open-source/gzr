RSpec.describe "`gzr role cat` command", type: :cli do
  it "executes `gzr role help cat` command successfully" do
    output = `gzr role help cat`
    expected_output = <<-OUT
Usage:
  gzr cat

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
