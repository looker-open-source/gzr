RSpec.describe "`lkr space tree` command", type: :cli do
  it "executes `space tree --help` command successfully" do
    output = `lkr space tree --help`
    expect(output).to eq <<-OUT
Usage:
  lkr space tree STARTING_SPACE

Options:
  -h, [--help], [--no-help]  # Display usage information

Display the dashbaords, looks, and subspaces or a space in a tree format
    OUT
  end
end
