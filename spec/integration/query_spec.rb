RSpec.describe "`gzr query` command", type: :cli do
  it "executes `gzr help query` command successfully" do
    output = `gzr help query`
    expected_output = <<-OUT
Commands:
  gzr query help [COMMAND]      # Describe subcommands or one specific subcommand
  gzr query runquery QUERY_DEF  # Run query_id, query_slug, or json_query_desc

    OUT

    expect(output).to eq(expected_output)
  end
end
