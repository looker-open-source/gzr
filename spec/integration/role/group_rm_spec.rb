RSpec.describe "`gzr role group_rm` command", type: :cli do
  it "executes `gzr role help group_rm` command successfully" do
    output = `gzr role help group_rm`
    expected_output = <<-OUT
Usage:
  gzr role group_rm ROLE_ID GROUP_ID GROUP_ID GROUP_ID ...

Options:
  -h, [--help], [--no-help]  # Display usage information

Remove indicated groups from role
    OUT

    expect(output).to eq(expected_output)
  end
end
