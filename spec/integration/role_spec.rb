RSpec.describe "`gzr role` command", type: :cli do
  it "executes `gzr help role` command successfully" do
    output = `gzr help role`
    expected_output = <<-OUT
Commands:
  gzr role cat ROLE_ID                                       # Output the JSON representation of a role to the screen or a file
  gzr role group_add ROLE_ID GROUP_ID GROUP_ID GROUP_ID ...  # Add indicated groups to role
  gzr role group_ls ROLE_ID                                  # List the groups assigned to a role
  gzr role group_rm ROLE_ID GROUP_ID GROUP_ID GROUP_ID ...   # Remove indicated groups from role
  gzr role help [COMMAND]                                    # Describe subcommands or one specific subcommand
  gzr role ls                                                # Display all roles
  gzr role rm ROLE_ID                                        # Delete a role
  gzr role user_add ROLE_ID USER_ID USER_ID USER_ID ...      # Add indicated users to role
  gzr role user_ls ROLE_ID                                   # List the users assigned to a role
  gzr role user_rm ROLE_ID USER_ID USER_ID USER_ID ...       # Remove indicated users from role

    OUT

    expect(output).to eq(expected_output)
  end
end
