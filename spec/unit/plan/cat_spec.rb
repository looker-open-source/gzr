require 'gzr/commands/plan/cat'

RSpec.describe Gzr::Commands::Plan::Cat do
  it "executes `plan cat` command successfully" do
    require 'sawyer'
    mock_response = double(Sawyer::Resource, { :id=>1, :name=>"foo" })
    allow(mock_response).to receive(:to_attrs).and_return({ :id=>1, :name=>"foo" })
    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:scheduled_plan) do |plan_id, body|
      return mock_response
    end

    output = StringIO.new
    options = {}
    command = Gzr::Commands::Plan::Cat.new(1,options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq <<-OUT
{
  "id": 1,
  "name": "foo"
}
    OUT
  end
end
