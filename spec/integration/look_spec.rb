RSpec.describe "`gzr look` command", type: :cli do
  it "executes `look --help` command successfully" do
    output = `gzr look --help`
    expect(output).to match <<-OUT
Commands:
    OUT
  end
end
