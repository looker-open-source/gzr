RSpec.describe "`gzr user enable` command", type: :cli do
  it "executes `gzr user help enable` command successfully" do
    output = `gzr user help enable`
    expected_output = <<-OUT
Usage:
  gzr user enable USER_ID

Options:
  -h, [--help], [--no-help]  # Display usage information

Enable the user given by user_id
    OUT

    expect(output).to eq(expected_output)
  end
end
