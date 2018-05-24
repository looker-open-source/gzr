RSpec.describe "`gzr look rm` command", type: :cli do
  it "executes `look rm --help` command successfully" do
    output = `gzr look rm --help`
    expect(output).to eq <<-OUT
Usage:
  gzr look rm LOOK_ID

Options:
  -h, [--help], [--no-help]  # Display usage information

Delete look given by LOOK_ID
    OUT
  end
end
