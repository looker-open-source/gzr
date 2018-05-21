RSpec.describe "`lkr connection dialects` command", type: :cli do
  it "executes `connection dialects --help` command successfully" do
    output = `lkr connection dialects --help`
    expect(output).to eq <<-OUT
Usage:
  lkr connection dialects

Options:
  -h, [--help], [--no-help]    # Display usage information
      [--fields=FIELDS]        # Fields to display
                               # Default: name,label
      [--plain], [--no-plain]  # print without any extra formatting
      [--csv], [--no-csv]      # output in csv format per RFC4180

List all available dialects
    OUT
  end
end
