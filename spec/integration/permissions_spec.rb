RSpec.describe "`gzr permissions` command", type: :cli do
  it "executes `gzr help permissions` command successfully" do
    output = `gzr help permissions`
    expected_output = <<-OUT
Commands:
  gzr permissions help [COMMAND]  # Describe subcommands or one specific subcommand
  gzr permissions ls              # List all available permissions

    OUT

    expect(output).to eq(expected_output)
  end
end
