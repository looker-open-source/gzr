RSpec.describe "`gzr plan` command", type: :cli do
  it "executes `gzr help plan` command successfully" do
    output = `gzr help plan`
    expected_output = <<-OUT
Commands:
  gzr plan cat PLAN_ID                       # Output the JSON representation of a scheduled plan to the screen or a file
  gzr plan help [COMMAND]                    # Describe subcommands or one specific subcommand
  gzr plan import PLAN_FILE OBJ_TYPE OBJ_ID  # Import a plan from a file
  gzr plan ls                                # List the scheduled plans on a server
  gzr plan rm PLAN_ID                        # Delete a scheduled plan
  gzr plan runit PLAN_ID                     # Execute a saved plan immediately

    OUT

    expect(output).to eq(expected_output)
  end
end
