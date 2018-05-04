RSpec.describe "`lkr look import` command", type: :cli do
  it "executes `look import --help` command successfully" do
    output = `lkr look import --help`
    expect(output).to eq <<-OUT
Usage:
  lkr look import FILE DEST_SPACE_ID

Options:
  -h, [--help], [--no-help]  # Display usage information

Import a look from a file
    OUT
  end
end
