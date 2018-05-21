RSpec.describe "`lkr space ls` command", type: :cli do
  it "executes `space ls --help` command successfully" do
    output = `lkr space ls --help`
    expect(output).to eq <<-OUT
Usage:
  lkr space ls FILTER_SPEC

Options:
  -h, [--help], [--no-help]    # Display usage information
      [--fields=FIELDS]        # Fields to display
                               # Default: parent_id,id,name,looks(id,title),dashboards(id,title)
      [--plain], [--no-plain]  # print without any extra formatting
      [--csv], [--no-csv]      # output in csv format per RFC4180

list the contents of a space given by space name, space_id, ~ for the current user's default space, or ~name / ~number for the home space of a user
    OUT
  end
end
