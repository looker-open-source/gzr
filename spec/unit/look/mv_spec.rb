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

require 'gzr/commands/look/mv'

RSpec.describe Gzr::Commands::Look::Mv do
  look_response_doc = {
    :id=>31415,
    :title=>"Daily Profit",
    :description=>"Total profit by day for the last 100 days",
    :query_id=>555,
    :user_id=>1000,
    :space_id=>1,
    :slug=>"123xyz"
  }.freeze

  define_method :mock_sdk do |block_hash={}|
    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:authenticated?) { true }
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:look) do |id|
      if block_hash && block_hash[:look]
        block_hash[:look].call(id)
      end
      doc = look_response_doc.dup
      HashResponse.new(doc)
    end
    mock_sdk.define_singleton_method(:update_look) do |id,req|
      if block_hash && block_hash[:update_look]
        block_hash[:update_look].call(id,req)
      end
      doc = look_response_doc.dup
      doc.merge!(req)
      HashResponse.new(doc)
    end
    mock_sdk.define_singleton_method(:search_looks) do |req|
      if req&.fetch(:space_id,nil) == 2 && req&.fetch(:title,nil) == "Daily Profit"
        []
      else
        []
      end
    end
    mock_sdk
  end

  it "executes `look mv` command successfully" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Look::Mv.new(31415,2,options)

    command.instance_variable_set(:@sdk, mock_sdk())

    command.execute(output: output)

    expect(output.string).to eq("Moved look 31415 to space 2\n")
  end
end
