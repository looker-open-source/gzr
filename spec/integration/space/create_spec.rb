RSpec.describe "`lkr space create` command", type: :cli do
  it "executes `space create --help` command successfully" do
    output = `lkr space create --help`
    expect(output).to eq <<-OUT
Usage:
  lkr create NAME,PARENT_SPACE

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT
  end
end
