RSpec.describe "`gzr dashboard` command", type: :cli do
  it "executes `dashboard --help` command successfully" do
    output = `gzr dashboard --help`
    expect(output).to match <<-OUT
Commands:
    OUT
  end
end
