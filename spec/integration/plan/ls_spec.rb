RSpec.describe "`gzr plan ls` command", type: :cli do
  it "executes `gzr plan help ls` command successfully" do
    output = `gzr plan help ls`
    expected_output = <<-OUT
Usage:
  gzr plan ls

Options:
  -h, [--help], [--no-help]    # Display usage information
      [--fields=FIELDS]        # Fields to display
                               # Default: id,name,title,user(id,display_name),look_id,dashboard_id,lookml_dashboard_id
      [--plain], [--no-plain]  # print without any extra formatting
      [--csv], [--no-csv]      # output in csv format per RFC4180

List the scheduled plans on a server
    OUT

    expect(output).to eq(expected_output)
  end
end
