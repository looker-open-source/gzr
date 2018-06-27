RSpec.describe "`gzr role user_ls` command", type: :cli do
  it "executes `gzr role help user_ls` command successfully" do
    output = `gzr role help user_ls`
    expected_output = <<-OUT
Usage:
  gzr user_ls

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
