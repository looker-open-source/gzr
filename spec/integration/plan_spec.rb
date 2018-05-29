RSpec.describe "`gzr plans` command", type: :cli do
  it "executes `gzr help plans` command successfully" do
    output = `gzr help plans`
    expected_output = <<-OUT
Commands:
    OUT

    expect(output).to eq(expected_output)
  end
end
