RSpec.describe "`gzr model` command", type: :cli do
  it "executes `model --help` command successfully" do
    output = `gzr model --help`
    expect(output).to match <<-OUT
Commands:
    OUT
  end
end
