# The MIT License (MIT)

# Copyright (c) 2024 Mike DeAngelo Google, Inc.

# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

RSpec.describe "`gzr alert` command", type: :cli do
  it "executes `gzr help alert` command successfully" do
    output = `gzr help alert`
    expected_output = <<-OUT
Commands:
  gzr alert cat ALERT_ID                        # Output json information about an alert to screen or file
  gzr alert chown ALERT_ID OWNER_ID             # Change the owner of the alert given by ALERT_ID to OWNER_ID
  gzr alert disable ALERT_ID REASON             # Disable the alert given by ALERT_ID
  gzr alert enable ALERT_ID                     # Enable the alert given by ALERT_ID
  gzr alert follow ALERT_ID                     # Start following the alert given by ALERT_ID
  gzr alert help [COMMAND]                      # Describe subcommands or one specific subcommand
  gzr alert import FILE [DASHBOARD_ELEMENT_ID]  # Import an alert from a file
  gzr alert ls                                  # list alerts
  gzr alert notifications                       # Get notifications
  gzr alert randomize                           # Randomize the scheduled alerts on a server
  gzr alert read NOTIFICATION_ID                # Read notification id
  gzr alert rm ALERT_ID                         # Delete the alert given by ALERT_ID
  gzr alert threshold ALERT_ID THRESHOLD        # Change the threshold of the alert given by ALERT_ID
  gzr alert unfollow ALERT_ID                   # Stop following the alert given by ALERT_ID

    OUT

    expect(output).to eq(expected_output)
  end
end
