require 'gzr/commands/role/group_ls'

RSpec.describe Gzr::Commands::Role::GroupLs do
  it "executes `role group_ls` command successfully" do
    require 'sawyer'
    groups = (100..105).collect do |i|
      group_doc = {
          :id=>i,
          :name=>"Group No#{i}",
      }
      mock_group = double(Sawyer::Resource, group_doc)
      allow(mock_group).to receive(:to_attrs).and_return(group_doc)
      mock_group
    end
    mock_sdk = Object.new
    allow(mock_sdk).to receive(:logout)
    allow(mock_sdk).to receive(:role_groups) do |role_id,body|
      groups
    end
    output = StringIO.new
    options = { :fields=>'id,name' }
    command = Gzr::Commands::Role::GroupLs.new(1,options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq <<-OUT
+---+-----------+
| id|name       |
+---+-----------+
|100|Group No100|
|101|Group No101|
|102|Group No102|
|103|Group No103|
|104|Group No104|
|105|Group No105|
+---+-----------+
    OUT
  end
end
