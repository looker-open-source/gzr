RSpec.describe "`gzr dashboard import` command", type: :cli do
  it "executes `dashboard import --help` command successfully" do
    output = `gzr dashboard import --help`
    expect(output).to eq <<-OUT
Usage:
  gzr dashboard import FILE DEST_SPACE_ID

Options:
  -h, [--help], [--no-help]    # Display usage information
      [--plain], [--no-plain]  # Provide minimal response information

Import a dashboard from a file
    OUT
  end
end
