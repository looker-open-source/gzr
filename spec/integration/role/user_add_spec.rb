RSpec.describe "`gzr role user_add` command", type: :cli do
  it "executes `gzr role help user_add` command successfully" do
    output = `gzr role help user_add`
    expected_output = <<-OUT
Usage:
  gzr user_add

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
