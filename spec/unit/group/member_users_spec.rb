require 'lkr/commands/group/member_users'

RSpec.describe Lkr::Commands::Group::MemberUsers do
  it "executes `member_users` command successfully" do
    require 'sawyer'
    mock_response_doc = { :id=>1, :last_name=>"foo", :first_name=>"bar", :email=>"fbar@my.company.com" }
    mock_response = double(Sawyer::Resource, mock_response_doc)
    allow(mock_response).to receive(:to_attrs).and_return(mock_response_doc)
    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:all_group_users) do |group_id,body|
      return body[:page] == 1 ? [mock_response] : []
    end

    output = StringIO.new
    options = { :fields=>'id,last_name,first_name,email' }
    command = Lkr::Commands::Group::MemberUsers.new(1,options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq <<-OUT
+--+---------+----------+-------------------+
|id|last_name|first_name|email              |
+--+---------+----------+-------------------+
| 1|foo      |bar       |fbar@my.company.com|
+--+---------+----------+-------------------+
    OUT
  end
end
