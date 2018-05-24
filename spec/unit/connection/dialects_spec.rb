require 'gzr/commands/connection/dialects'

RSpec.describe Gzr::Commands::Connection::Dialects do
  it "executes `dialects` command successfully" do
    require 'sawyer'
    response_doc = { :name=>"foo", :label=>"Foo" }
    mock_response = double(Sawyer::Resource, response_doc)
    allow(mock_response).to receive(:to_attrs).and_return(response_doc)
    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:authenticated?) { true }
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:all_dialect_infos) do |req|
      return [mock_response]
    end

    output = StringIO.new
    options = { :fields=>'name,label' }
    command = Gzr::Commands::Connection::Dialects.new(options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq <<-OUT
+----+-----+
|name|label|
+----+-----+
|foo |Foo  |
+----+-----+
    OUT
  end
end
