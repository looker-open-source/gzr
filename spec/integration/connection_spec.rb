RSpec.describe "`lkr connection` command", type: :cli do
  it "executes `connection --help` command successfully" do
    output = `lkr connection --help`
    expect(output).to match <<-OUT
Commands:
    OUT
  end
end
