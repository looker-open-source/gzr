RSpec.describe "`gzr attribute` command", type: :cli do
  it "executes `gzr help attribute` command successfully" do
    output = `gzr help attribute`
    expected_output = <<-OUT
Commands:
    OUT

    expect(output).to eq(expected_output)
  end
end
