# The MIT License (MIT)

# Copyright (c) 2018 Mike DeAngelo Looker Data Sciences, Inc.

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

require 'gzr/commands/role/cat'

RSpec.describe Gzr::Commands::Role::Cat do
  it "executes `role cat` command successfully" do
    require 'sawyer'
    role_doc = <<-DOC
{
  "id": 100,
  "name": "Mock Role",
  "permission_set": {
    "id": 2,
    "name": "Developer",
    "permissions": [
      "access_data",
      "create_table_calculations",
      "deploy",
      "develop",
      "download_without_limit",
      "explore",
      "manage_folders",
      "save_content",
      "schedule_look_emails",
      "see_lookml",
      "see_lookml_dashboards",
      "see_looks",
      "see_sql",
      "see_user_dashboards",
      "use_sql_runner"
    ],
    "built_in": false,
    "all_access": false,
    "url": "https://localhost:19999/api/3.0/permission_sets/2",
    "can": {
    }
  },
  "model_set": {
    "id": 80,
    "name": "mock_modelset",
    "models": [
      "mock_model"
    ],
    "built_in": false,
    "all_access": false,
    "url": "https://localhost:19999/api/3.0/model_sets/80",
    "can": {
    }
  },
  "url": "https://localhost:19999/api/3.0/roles/100",
  "users_url": "https://localhost:19999/api/3.0/roles/100/users",
  "can": {
    "show": true,
    "index": true,
    "update": true
  }
}
    DOC
    role_json = JSON.parse(role_doc)
    mock_role = double(Sawyer::Resource, role_json)
    allow(mock_role).to receive(:to_attrs).and_return(role_json)
    mock_sdk = Object.new
    allow(mock_sdk).to receive(:logout)
    allow(mock_sdk).to receive(:role) do |role_id,body|
      mock_role
    end
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Role::Cat.new(100,options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq role_doc
  end
end
