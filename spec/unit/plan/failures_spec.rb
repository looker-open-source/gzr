# The MIT License (MIT)

# Copyright (c) 2018 Mike DeAngelo Looker Data Sciences, Inc.

# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
    options = {:width=>1024}
    command = Gzr::Commands::Plan::Failures.new(options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq <<-OUT
+-----------------+-------------------+-------+------------+--------------------+----------------+--------------------------+----------------------------+----------------------+---------------------------+----------------------------------+
|scheduled_plan.id|scheduled_plan.name|user.id|user.name   |scheduled_job.status|scheduled_job.id|scheduled_job.created_time|scheduled_plan.next_run_time|scheduled_plan.look_id|scheduled_plan.dashboard_id|scheduled_plan.lookml_dashboard_id|
+-----------------+-------------------+-------+------------+--------------------+----------------+--------------------------+----------------------------+----------------------+---------------------------+----------------------------------+
|               23|                   |       |Jake Johnson|failure             |           13694|2018-06-19 11:00:32       |2018-06-20 11:00:00         |                      |                           |                                  |
+-----------------+-------------------+-------+------------+--------------------+----------------+--------------------------+----------------------------+----------------------+---------------------------+----------------------------------+
    OUT
  end
end
