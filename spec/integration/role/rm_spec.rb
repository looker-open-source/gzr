RSpec.describe "`gzr role rm` command", type: :cli do
  it "executes `gzr role help rm` command successfully" do
    output = `gzr role help rm`
    expected_output = <<-OUT
Usage:
  gzr rm

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
