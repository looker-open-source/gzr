RSpec.describe "`gzr model ls` command", type: :cli do
  it "executes `model ls --help` command successfully" do
    output = `gzr model ls --help`
    expect(output).to eq <<-OUT
Usage:
  gzr model ls

Options:
  -h, [--help], [--no-help]    # Display usage information
      [--fields=FIELDS]        # Fields to display
                               # Default: name,label,project_name
      [--plain], [--no-plain]  # print without any extra formatting
      [--csv], [--no-csv]      # output in csv format per RFC4180

List the models in this server.
    OUT
  end
end
