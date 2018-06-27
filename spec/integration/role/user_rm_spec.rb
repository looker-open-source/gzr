RSpec.describe "`gzr role user_rm` command", type: :cli do
  it "executes `gzr role help user_rm` command successfully" do
    output = `gzr role help user_rm`
    expected_output = <<-OUT
Usage:
  gzr user_rm

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
