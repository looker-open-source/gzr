RSpec.describe "`gzr space top` command", type: :cli do
  it "executes `space top --help` command successfully" do
    output = `gzr space top --help`
    expect(output).to eq <<-OUT
Usage:
  gzr space top

Options:
  -h, [--help], [--no-help]    # Display usage information
      [--plain], [--no-plain]  # print without any extra formatting
      [--csv], [--no-csv]      # output in csv format per RFC4180

Retrieve the top level (or root) spaces
    OUT
  end
end
