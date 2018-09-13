RSpec.describe "`gzr query runquery` command", type: :cli do
  it "executes `gzr query help runquery` command successfully" do
    output = `gzr query help runquery`
    expected_output = <<-OUT
Usage:
  gzr query runquery QUERY_DEF

Options:
  -h, [--help], [--no-help]  # Display usage information
      [--file=FILE]          # Filename for saved data
      [--format=FORMAT]      # One of json,json_detail,csv,txt,html,md,xlsx,sql,png,jpg
                             # Default: json

Run query_id, query_slug, or json_query_desc
    OUT

    expect(output).to eq(expected_output)
  end
end
