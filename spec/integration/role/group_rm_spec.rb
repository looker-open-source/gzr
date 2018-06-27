RSpec.describe "`gzr role group_rm` command", type: :cli do
  it "executes `gzr role help group_rm` command successfully" do
    output = `gzr role help group_rm`
    expected_output = <<-OUT
Usage:
  gzr group_rm

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
