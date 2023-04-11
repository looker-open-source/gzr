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

require 'gzr/commands/folder/top'

RSpec.describe Gzr::Commands::Folder::Top do
  it "executes `top` command successfully" do
    require 'sawyer'
    mock_folders = Array.new
    (1..6).each do |i|
      h = {
        :id=>i,
        :name=>"Folder #{i}",
        :is_shared_root=>i==1,
        :is_users_root=>i==2,
        :is_embed_shared_root=>i==5,
        :is_embed_users_root=>i==5,
      }
      m = double(Sawyer::Resource, h)
      allow(m).to receive(:to_attrs).and_return(h)
      allow(m).to receive(:name).and_return(h[:name])
      allow(m).to receive(:is_shared_root).and_return(h[:is_shared_root])
      allow(m).to receive(:is_users_root).and_return(h[:is_users_root])
      allow(m).to receive(:is_embed_shared_root).and_return(h[:is_embed_shared_root])
      allow(m).to receive(:is_embed_users_root).and_return(h[:is_embed_users_root])
      mock_folders << m
    end
    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:all_folders) do |body|
      return mock_folders
    end

    output = StringIO.new
    options = {:fields => 'id,name,is_shared_root,is_users_root,is_embed_shared_root,is_embed_users_root'}
    options[:width] = 130
    command = Gzr::Commands::Folder::Top.new(options)

    command.instance_variable_set(:@sdk, mock_sdk)

    command.execute(output: output)

    expect(output.string).to eq <<-OUT
+--+--------+--------------+-------------+--------------------+-------------------+
|id|name    |is_shared_root|is_users_root|is_embed_shared_root|is_embed_users_root|
+--+--------+--------------+-------------+--------------------+-------------------+
| 1|Folder 1|true          |false        |false               |false              |
| 2|Folder 2|false         |true         |false               |false              |
| 5|Folder 5|false         |false        |true                |true               |
+--+--------+--------------+-------------+--------------------+-------------------+
    OUT
  end
end
