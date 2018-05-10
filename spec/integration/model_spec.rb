RSpec.describe "`lkr model` command", type: :cli do
  it "executes `model --help` command successfully" do
    output = `lkr model --help`
    expect(output).to match <<-OUT
Commands:
    OUT
  end
end
