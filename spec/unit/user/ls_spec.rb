require 'gzr/commands/user/ls'

RSpec.describe Gzr::Commands::User::Ls do
  it "executes `ls` command successfully" do
    require 'sawyer'
    mock_response = double(Sawyer::Resource, { :id=>1, :last_name=>"foo", :first_name=>"bar", :email=>"fbar@my.company.com" })
    allow(mock_response).to receive(:to_attrs).and_return({ :id=>1, :last_name=>"foo", :first_name=>"bar", :email=>"fbar@my.company.com" })
    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:all_users) do |body|
      return body[:page] == 1 ? [mock_response] : []
    end

    output = StringIO.new
    options = { :fields=>'id,last_name,first_name,email' }
    command = Gzr::Commands::User::Ls.new(options)

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
