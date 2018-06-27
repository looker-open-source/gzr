RSpec.describe "`gzr role group_add` command", type: :cli do
  it "executes `gzr role help group_add` command successfully" do
    output = `gzr role help group_add`
    expected_output = <<-OUT
Usage:
  gzr group_add

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
