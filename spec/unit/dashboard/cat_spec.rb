require 'gzr/commands/dashboard/cat'

RSpec.describe Gzr::Commands::Dashboard::Cat do
  it "executes `dashboard cat` command successfully" do
    require 'sawyer'
    dashboard = { :id=>1, :title=>"foo", :dashboard_elements=>[] }
    mock_response = double(Sawyer::Resource, dashboard)
    allow(mock_response).to receive(:to_attrs).and_return(dashboard)
    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:dashboard) do |dashboard_id|
      return mock_response
    end

    output = StringIO.new
    options = { dir: nil }
    command = Gzr::Commands::Dashboard::Cat.new(1,options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq <<-OUT
{
  "id": 1,
  "title": "foo",
  "dashboard_elements": [

  ]
}
    OUT
  end
end
