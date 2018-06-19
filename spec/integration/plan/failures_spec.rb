RSpec.describe "`gzr plan failures` command", type: :cli do
  it "executes `gzr plan help failures` command successfully" do
    output = `gzr plan help failures`
    expected_output = <<-OUT
Usage:
  gzr plan failures

Options:
  -h, [--help], [--no-help]    # Display usage information
      [--plain], [--no-plain]  # print without any extra formatting
      [--csv], [--no-csv]      # output in csv format per RFC4180

Report all plans that failed in their most recent run attempt
    OUT

    expect(output).to eq(expected_output)
  end
end
