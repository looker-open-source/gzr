require 'gzr/commands/plan/ls'

RSpec.describe Gzr::Commands::Plan::Ls do
  it "executes `plan ls` command successfully" do
    require 'sawyer'
    user_doc = {
        :id=>1000,
        :display_name=>"John Smith"
    }
    mock_user = double(Sawyer::Resource, user_doc)
    allow(mock_user).to receive(:to_attrs).and_return(user_doc)
    response_doc = {
      :id=>1,
      :name=>"foo",
      :title=>"foo",
      :user=>mock_user,
      :look_id=>100,
      :dashboard_id=>nil,
      :lookml_dashboard_id=>nil
    }
    mock_response = double(Sawyer::Resource, response_doc)
    allow(mock_response).to receive(:to_attrs).and_return(response_doc)
    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:all_scheduled_plans) do |body|
      return [mock_response,mock_response]
    end

    output = StringIO.new
    options = {:fields=>'id,name,title,user(id,display_name),look_id,dashboard_id,lookml_dashboard_id'}
    command = Gzr::Commands::Plan::Ls.new(options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq <<-OUT
+--+----+-----+-------+-----------------+-------+------------+-------------------+
|id|name|title|user.id|user.display_name|look_id|dashboard_id|lookml_dashboard_id|
+--+----+-----+-------+-----------------+-------+------------+-------------------+
| 1|foo |foo  |   1000|John Smith       |    100|            |                   |
| 1|foo |foo  |   1000|John Smith       |    100|            |                   |
+--+----+-----+-------+-----------------+-------+------------+-------------------+
    OUT
  end
end
