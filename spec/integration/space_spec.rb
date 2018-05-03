RSpec.describe "`lkr space` command", type: :cli do
  it "executes `space --help` command successfully" do
    output = `lkr space --help`
    expect(output).to match <<-OUT
Commands:
    OUT
  end
end
