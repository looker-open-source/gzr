RSpec.describe "`gzr attribute create` command", type: :cli do
  it "executes `gzr attribute help create` command successfully" do
    output = `gzr attribute help create`
    expected_output = <<-OUT
Usage:
  gzr attribute create ATTR_NAME [ATTR_LABEL] [OPTIONS]

Options:
  -h, [--help], [--no-help]                  # Display usage information
      [--plain], [--no-plain]                # Provide minimal response information
      [--force]                              # If the user attribute already exists, modify it
      [--type=TYPE]                          # "string", "number", "datetime", "yesno", "zipcode"
                                             # Default: string
      [--default-value=DEFAULT-VALUE]        # default value to be used if one not otherwise set
      [--is-hidden], [--no-is-hidden]        # can a non-admin user view the value
      [--can-view], [--no-can-view]          # can a non-admin user view the value
                                             # Default: true
      [--can-edit], [--no-can-edit]          # can a user change the value themself
                                             # Default: true
      [--domain-whitelist=DOMAIN-WHITELIST]  # what domains can receive the value of a hidden attribute.

Create or modify an attribute
    OUT

    expect(output).to eq(expected_output)
  end
end
