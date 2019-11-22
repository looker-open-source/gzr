RSpec.describe "`gzr attribute ls` command", type: :cli do
  it "executes `gzr attribute help ls` command successfully" do
    output = `gzr attribute help ls`
    expected_output = <<-OUT
Usage:
  gzr attribute ls

Options:
  -h, [--help], [--no-help]    # Display usage information
      [--fields=FIELDS]        # Fields to display
                               # Default: id,name,label,type,default_value
      [--plain], [--no-plain]  # print without any extra formatting
      [--csv], [--no-csv]      # output in csv format per RFC4180

List all the defined user attributes
    OUT

    expect(output).to eq(expected_output)
  end
end
