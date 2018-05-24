RSpec.describe "`gzr connection ls` command", type: :cli do
  it "executes `connection ls --help` command successfully" do
    output = `gzr connection ls --help`
    expect(output).to eq <<-OUT
Usage:
  gzr connection ls

Options:
  -h, [--help], [--no-help]    # Display usage information
      [--fields=FIELDS]        # Fields to display
                               # Default: name,dialect(name),host,port,database,schema
      [--plain], [--no-plain]  # print without any extra formatting
      [--csv], [--no-csv]      # output in csv format per RFC4180

List all available connections
    OUT
  end
end
