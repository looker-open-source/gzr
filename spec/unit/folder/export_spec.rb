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

require 'gzr/commands/folder/export'

RSpec.describe Gzr::Commands::Folder::Export do
  me_response_doc = {
    :id=>1000,
    :first_name=>"John",
    :last_name=>"Jones",
    :email=>"jjones@example.com",
    :home_folder_id=>314159,
    :personal_folder_id=>1088
  }.freeze

  mock_looks = [
    {:id=>101, :folder_id=>2, :title=>"Look 101"},
    {:id=>102, :folder_id=>2, :title=>"Look 102"},
    {:id=>103, :folder_id=>3, :title=>"Look 103"},
    {:id=>104, :folder_id=>3, :title=>"Look 104 with / in name"},
    {:id=>105, :folder_id=>5, :title=>"Look 105"},
    {:id=>106, :folder_id=>5, :title=>"Look 106 with / in name"}
  ]

  mock_dashboards = [
    {:id=>201, :folder_id=>2, :title=>"Dash 201", :dashboard_elements=>[]},
    {:id=>202, :folder_id=>2, :title=>"Dash 202", :dashboard_elements=>[]},
    {:id=>203, :folder_id=>3, :title=>"Dash 203", :dashboard_elements=>[]},
    {:id=>204, :folder_id=>3, :title=>"Dash 204 with / in name", :dashboard_elements=>[]},
    {:id=>205, :folder_id=>5, :title=>"Dash 205", :dashboard_elements=>[]},
    {:id=>206, :folder_id=>5, :title=>"Dash 206 with / in name", :dashboard_elements=>[]}
  ]

  mock_folders = Array.new
  mock_folders << {
    :id=>1,
    :name=>"Folder 1",
    :looks=>[ ],
    :dashboards=>[ ],
    :parent_id=>nil
  }
  mock_folders << {
    :id=>2,
    :name=>"Folder 2",
    :looks=>mock_looks.select {|l| l[:folder_id] == 2}.map{|l| HashResponse.new(l)},
    :dashboards=>mock_dashboards.select {|d| d[:folder_id] == 2}.map{|d| HashResponse.new(d)},
    :parent_id=>1
  }
  mock_folders << {
    :id=>5,
    :name=>"Folder 5",
    :looks=>mock_looks.select {|l| l[:folder_id] == 5}.map{|l| HashResponse.new(l)},
    :dashboards=>mock_dashboards.select {|d| d[:folder_id] == 5}.map{|d| HashResponse.new(d)},
    :parent_id=>1
  }
  mock_folders << {
    :id=>3,
    :name=>"Folder with / in name",
    :looks=>mock_looks.select {|l| l[:folder_id] == 3}.map{|l| HashResponse.new(l)},
    :dashboards=>mock_dashboards.select {|d| d[:folder_id] == 3}.map{|d| HashResponse.new(d)},
    :parent_id=>2
  }
  mock_folders << {
    :id=>4,
    :name=>nil,
    :looks=>[],
    :dashboards=>[ ],
    :parent_id=>2
  }

  define_method :mock_sdk do |block_hash={}|
    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:authenticated?) { true }
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:me) do |req|
      HashResponse.new(me_response_doc)
    end
    mock_sdk.define_singleton_method(:search_folders) do |req|
      if block_hash && block_hash[:search_folders]
        block_hash[:search_folders].call(req)
      end
      doc = dash_response_doc.dup
      doc[:id] += 1
      HashResponse.new(doc)
    end
    mock_sdk.define_singleton_method(:folder) do |id,req|
      if block_hash && block_hash[:folder]
        block_hash[:folder].call(id,req)
      end
      docs = mock_folders.select {|s| s[:id] == id}
      return HashResponse.new(docs.first) unless docs.empty?
      nil
    end
    mock_sdk.define_singleton_method(:look) do |id|
      if block_hash && block_hash[:look]
        block_hash[:look].call(id)
      end
      docs = mock_looks.select {|l| l[:id] == id}
      return HashResponse.new(docs.first) unless docs.empty?
      nil
    end
    mock_sdk.define_singleton_method(:dashboard) do |id|
      if block_hash && block_hash[:dashboard]
        block_hash[:dashboard].call(id)
      end
      docs = mock_dashboards.select {|d| d[:id] == id}
      return HashResponse.new(docs.first) unless docs.empty?
      nil
    end
    mock_sdk.define_singleton_method(:folder_children) do |id,req|
      if block_hash && block_hash[:folder_children]
        block_hash[:folder_children].call(id,req)
      end
      docs = mock_folders.select {|s| s[:parent_id] == id}
      return docs.map {|d| HashResponse.new(d)}
    end
    mock_sdk
  end

  require 'rubygems/package'

  it "executes `export` command successfully" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Folder::Export.new(1,options)

    command.instance_variable_set(:@sdk, mock_sdk)

    mock_tar_writer = double(Gem::Package::TarWriter)

    mock_tar_writer.define_singleton_method(:mkdir) do |name,mode|
      output.puts "mkdir #{name},#{mode}"
    end

    mock_tar_writer.define_singleton_method(:add_file) do |name,mode|
      output.puts "add_file #{name},#{mode}"
    end

    command.process_folder(1,mock_tar_writer)

    expect(output.string).to eq <<-OUT
mkdir Folder 1,493
add_file Folder 1/Folder_1_Folder 1.json,420
mkdir Folder 1/Folder 2,493
add_file Folder 1/Folder 2/Folder_2_Folder 2.json,420
add_file Folder 1/Folder 2/Look_101_Look 101.json,420
add_file Folder 1/Folder 2/Look_102_Look 102.json,420
add_file Folder 1/Folder 2/Dashboard_201_Dash 201.json,420
add_file Folder 1/Folder 2/Dashboard_202_Dash 202.json,420
mkdir Folder 1/Folder 2/Folder with ∕ in name,493
add_file Folder 1/Folder 2/Folder with ∕ in name/Folder_3_Folder with ∕ in name.json,420
add_file Folder 1/Folder 2/Folder with ∕ in name/Look_103_Look 103.json,420
add_file Folder 1/Folder 2/Folder with ∕ in name/Look_104_Look 104 with ∕ in name.json,420
add_file Folder 1/Folder 2/Folder with ∕ in name/Dashboard_203_Dash 203.json,420
add_file Folder 1/Folder 2/Folder with ∕ in name/Dashboard_204_Dash 204 with ∕ in name.json,420
mkdir Folder 1/Folder 2/nil (4),493
add_file Folder 1/Folder 2/nil (4)/Folder_4_nil (4).json,420
mkdir Folder 1/Folder 5,493
add_file Folder 1/Folder 5/Folder_5_Folder 5.json,420
add_file Folder 1/Folder 5/Look_105_Look 105.json,420
add_file Folder 1/Folder 5/Look_106_Look 106 with ∕ in name.json,420
add_file Folder 1/Folder 5/Dashboard_205_Dash 205.json,420
add_file Folder 1/Folder 5/Dashboard_206_Dash 206 with ∕ in name.json,420
    OUT
  end
end
