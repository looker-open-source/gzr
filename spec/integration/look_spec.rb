RSpec.describe "`lkr look` command", type: :cli do
  it "executes `look --help` command successfully" do
    output = `lkr look --help`
    expect(output).to match <<-OUT
Commands:
    OUT
  end
end
