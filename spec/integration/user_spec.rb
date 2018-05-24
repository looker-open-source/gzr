RSpec.describe "`gzr user` command", type: :cli do
  it "executes `user --help` command successfully" do
    output = `gzr user --help`
    expect(output).to match <<-OUT
Commands:
    OUT
  end
end
