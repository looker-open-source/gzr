RSpec.describe "`gzr connection` command", type: :cli do
  it "executes `connection --help` command successfully" do
    output = `gzr connection --help`
    expect(output).to match <<-OUT
Commands:
    OUT
  end
end
