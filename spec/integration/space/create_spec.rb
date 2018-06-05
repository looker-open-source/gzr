RSpec.describe "`gzr space create` command", type: :cli do
  it "executes `space create --help` command successfully" do
    output = `gzr space create --help`
    expect(output).to eq <<-OUT
Usage:
  gzr space create NAME PARENT_SPACE

Options:
  -h, [--help], [--no-help]    # Display usage information
      [--plain], [--no-plain]  # Provide minimal response information

Command description...
    OUT
  end
end
