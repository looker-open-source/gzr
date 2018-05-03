RSpec.describe "`lkr dashboard` command", type: :cli do
  it "executes `dashboard --help` command successfully" do
    output = `lkr dashboard --help`
    expect(output).to match <<-OUT
Commands:
    OUT
  end
end
