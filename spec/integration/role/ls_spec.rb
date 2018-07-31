RSpec.describe "`gzr role ls` command", type: :cli do
  it "executes `gzr role help ls` command successfully" do
    output = `gzr role help ls`
    expected_output = <<-OUT
Usage:
  gzr role ls

Options:
  -h, [--help], [--no-help]    # Display usage information
      [--fields=FIELDS]        # Fields to display
                               # Default: id,name,permission_set(id,name,permissions),model_set(id,name,models)
      [--plain], [--no-plain]  # print without any extra formatting
      [--csv], [--no-csv]      # output in csv format per RFC4180

Display all roles
    OUT

    expect(output).to eq(expected_output)
  end
end
