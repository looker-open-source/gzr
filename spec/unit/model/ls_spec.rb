require 'lkr/commands/model/ls'

RSpec.describe Lkr::Commands::Model::Ls do
  it "executes `ls` command successfully" do
    require 'sawyer'
    response_doc = { :name=>"foo", :label=>"bar", :project_name=>"baz" }
    mock_response = double(Sawyer::Resource, response_doc)
    allow(mock_response).to receive(:to_attrs).and_return(response_doc)
    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:authenticated?) { true }
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:all_lookml_models) do |req|
      return [mock_response]
    end

    output = StringIO.new
    options = {}
    command = Lkr::Commands::Model::Ls.new(options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq <<-OUT
+----+-----+------------+
|name|label|project_name|
+----+-----+------------+
|foo |bar  |baz         |
+----+-----+------------+
    OUT
  end
end
