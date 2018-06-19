require 'gzr/commands/plan/failures'

RSpec.describe Gzr::Commands::Plan::Failures do
  it "executes `plan failures` command successfully" do
    require 'sawyer'
    response_doc = {
      :"scheduled_plan.id"=>23,
      :"user.name"=>"Jake Johnson",
      :"scheduled_job.status"=>"failure",
      :"scheduled_job.id"=>13694,
      :"scheduled_job.created_time"=>"2018-06-19 11:00:32",
      :"scheduled_plan.next_run_time"=>"2018-06-20 11:00:00"
    }
    mock_response = double(Sawyer::Resource, response_doc)
    allow(mock_response).to receive(:to_attrs).and_return(response_doc)
    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:run_inline_query) do |format,query|
      return [mock_response]
    end

    output = StringIO.new
    options = {}
    command = Gzr::Commands::Plan::Failures.new(options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq <<-OUT
+-----------------+------------+--------------------+----------------+--------------------------+----------------------------+
|scheduled_plan.id|user.name   |scheduled_job.status|scheduled_job.id|scheduled_job.created_time|scheduled_plan.next_run_time|
+-----------------+------------+--------------------+----------------+--------------------------+----------------------------+
|               23|Jake Johnson|failure             |           13694|2018-06-19 11:00:32       |2018-06-20 11:00:00         |
+-----------------+------------+--------------------+----------------+--------------------------+----------------------------+
    OUT
  end
end
