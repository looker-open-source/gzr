RSpec.describe "`lkr user` command", type: :cli do
  it "executes `user --help` command successfully" do
    output = `lkr user --help`
    expect(output).to match <<-OUT
Commands:
    OUT
  end
end
