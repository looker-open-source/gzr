RSpec.describe "`gzr query` command", type: :cli do
  it "executes `gzr help query` command successfully" do
    output = `gzr help query`
    expected_output = <<-OUT
Commands:
    OUT

    expect(output).to eq(expected_output)
  end
end
