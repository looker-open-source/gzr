RSpec.describe "`gzr role` command", type: :cli do
  it "executes `gzr help role` command successfully" do
    output = `gzr help role`
    expected_output = <<-OUT
Commands:
    OUT

    expect(output).to eq(expected_output)
  end
end
