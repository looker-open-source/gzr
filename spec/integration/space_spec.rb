RSpec.describe "`gzr space` command", type: :cli do
  it "executes `space --help` command successfully" do
    output = `gzr space --help`
    expect(output).to match <<-OUT
Commands:
    OUT
  end
end
