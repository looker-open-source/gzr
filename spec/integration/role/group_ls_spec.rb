RSpec.describe "`gzr role group_ls` command", type: :cli do
  it "executes `gzr role help group_ls` command successfully" do
    output = `gzr role help group_ls`
    expected_output = <<-OUT
Usage:
  gzr group_ls

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
