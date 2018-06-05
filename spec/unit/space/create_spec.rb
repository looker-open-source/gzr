require 'gzr/commands/space/create'

RSpec.describe Gzr::Commands::Space::Create do
  it "executes `create` command successfully" do
    require 'sawyer'
    resp_hash = {
      :id=>1,
      :name=>"foo",
      :parent_id=>0,
      :looks=>[
        {
          :id=>2,
          :title=>"bar"
        }
      ],
      :dashboards=>[
        {
          :id=>3,
          :title=>"baz"
        }
      ]
    }
    mock_response = double(Sawyer::Resource, resp_hash)
    allow(mock_response).to receive(:to_attrs).and_return(resp_hash)
    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:create_space) do |req|
      return mock_response
    end

    output = StringIO.new
    options = {}
    command = Gzr::Commands::Space::Create.new("new space", 1, options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq("Created space 1\n")
  end
end
