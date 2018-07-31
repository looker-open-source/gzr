RSpec.describe "`gzr role user_rm` command", type: :cli do
  it "executes `gzr role help user_rm` command successfully" do
    output = `gzr role help user_rm`
    expected_output = <<-OUT
Usage:
  gzr role user_rm ROLE_ID USER_ID USER_ID USER_ID ...

Options:
  -h, [--help], [--no-help]  # Display usage information

Remove indicated users from role
    OUT

    expect(output).to eq(expected_output)
  end
end
