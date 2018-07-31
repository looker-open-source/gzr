RSpec.describe "`gzr role user_add` command", type: :cli do
  it "executes `gzr role help user_add` command successfully" do
    output = `gzr role help user_add`
    expected_output = <<-OUT
Usage:
  gzr role user_add ROLE_ID USER_ID USER_ID USER_ID ...

Options:
  -h, [--help], [--no-help]  # Display usage information

Add indicated users to role
    OUT

    expect(output).to eq(expected_output)
  end
end
