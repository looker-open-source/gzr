require 'gzr/commands/look/cat'

RSpec.describe Gzr::Commands::Look::Cat do
  it "executes `look cat` command successfully" do
    require 'sawyer'
    mock_response = double(Sawyer::Resource, { :id=>1, :title=>"foo" })
    allow(mock_response).to receive(:to_attrs).and_return({ :id=>1, :title=>"foo" })
    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:look) do |look_id|
      return mock_response
    end

    output = StringIO.new
    options = {}
    command = Gzr::Commands::Look::Cat.new(1,options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq <<-OUT
{
  "id": 1,
  "title": "foo"
}
    OUT
  end
end
