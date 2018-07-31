require 'gzr/commands/role/group_add'

RSpec.describe Gzr::Commands::Role::GroupAdd do
  it "executes `role group_add` command successfully" do
    require 'sawyer'
    groups = (100..105).collect do |i|
      group_doc = {
          :id=>i
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
    allow(mock_sdk).to receive(:set_role_groups) do |role_id,body|
      expect(body).to contain_exactly(100, 101, 102, 103, 104, 105, 106)
      nil 
    end
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Role::GroupAdd.new(1,[106],options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq("")
  end
end
