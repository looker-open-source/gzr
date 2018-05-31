RSpec.describe "`gzr user disable` command", type: :cli do
  it "executes `gzr user help disable` command successfully" do
    output = `gzr user help disable`
    expected_output = <<-OUT
Usage:
  gzr user disable USER_ID

Options:
  -h, [--help], [--no-help]  # Display usage information

Disable the user given by user_id
    OUT

    expect(output).to eq(expected_output)
  end
end
