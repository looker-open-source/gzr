require 'gzr/commands/query/runquery'

RSpec.describe Gzr::Commands::Query::RunQuery do
  it "executes `query runquery` command successfully" do
    require 'sawyer'
    data = <<-OUT
Orders Created Month	Orders Count	Customers Count
2018-09	31	31
2018-08	75	68
2018-07	83	73
2018-06	89	78
2018-05	78	63
2018-04	79	74
    OUT
    mock_sdk = Object.new
    allow(mock_sdk).to receive(:logout)
    allow(mock_sdk).to receive(:query) do |body|
    end
    allow(mock_sdk).to receive(:run_query) do |query_id,body,&block|
      block.call(data, data.length)
    end

    output = StringIO.new
    options = {}
    command = Gzr::Commands::Query::RunQuery.new("1",{:format => 'txt'})

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq(data)
  end
end
