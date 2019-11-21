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

require 'gzr/commands/attribute/get_group_value'

RSpec.describe Gzr::Commands::Attribute::GetGroupValue do
  groups = [
    {
      :id=>1,
      :name=>"group_1"
    }.freeze,
    {
      :id=>2,
      :name=>"group_2"
    }.freeze,
    {
      :id=>3,
      :name=>"group_3"
    }.freeze
  ]
  attrs = [
    {
      :id=>1,
      :name=>"attribute_1",
      :label=>"Attribute 1",
      :type=>"string",
      :default_value=>nil,
      :is_system=>true,
      :is_permanent=>nil,
      :value_is_hidden=>false,
      :user_can_view=>true,
      :user_can_edit=>true,
      :hidden_value_domain_whitelist=>nil
    }.freeze,
    {
      :id=>2,
      :name=>"attribute_2",
      :label=>"Attribute 2",
      :type=>"number",
      :default_value=>5,
      :is_system=>false,
      :is_permanent=>nil,
      :value_is_hidden=>false,
      :user_can_view=>true,
      :user_can_edit=>true,
      :hidden_value_domain_whitelist=>nil
    }.freeze,
    {
      :id=>3,
      :name=>"attribute_3",
      :label=>"Attribute 3",
      :type=>"string",
      :default_value=>nil,
      :is_system=>false,
      :is_permanent=>nil,
      :value_is_hidden=>false,
      :user_can_view=>true,
      :user_can_edit=>false,
      :hidden_value_domain_whitelist=>nil
    }.freeze
  ]

  define_method :mock_sdk do |block_hash={}|
    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:authenticated?) { true }
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:operations) { operations }
    mock_sdk.define_singleton_method(:swagger) { swagger }
    mock_sdk.define_singleton_method(:group) do |id,req|
      if block_hash && block_hash[:group]
        block_hash[:group].call(id,req)
      end
      found = groups.select {|a| a[:id] == id.to_i }
      return HashResponse.new(found.first) if found && !found.empty?
      nil
    end
    mock_sdk.define_singleton_method(:search_groups) do |req|
      if block_hash && block_hash[:search_groups]
        block_hash[:search_groups].call(req)
      end
      found = groups.select {|a| a[:name] == req[:name] }
      return nil if found.nil? || found.empty?
      found.map{|a| HashResponse.new(a)}
    end
    mock_sdk.define_singleton_method(:all_user_attributes) do |req|
      if block_hash && block_hash[:all_user_attributes]
        block_hash[:all_user_attributes].call(req)
      end
      attrs.map {|a| HashResponse.new(a)}
    end
    mock_sdk.define_singleton_method(:user_attribute) do |id,req|
      if block_hash && block_hash[:user_attribute]
        block_hash[:user_attribute].call(id,req)
      end
      found = attrs.select {|a| a[:id] == id.to_i }
      return HashResponse.new(found.first) if found && !found.empty?
      nil
    end
    mock_sdk.define_singleton_method(:all_user_attribute_group_values) do |id,req|
      if block_hash && block_hash[:all_user_attribute_group_values]
        block_hash[:all_user_attribute_group_values].call(id,req)
      end
      found_attrs = attrs.select {|a| a[:id] == id.to_i }
      return nil if found_attrs.nil? || found_attrs.empty?
      values = [
        [nil, nil,    nil,     nil],
        [nil, 'Test', nil,     'Test2'],
        [nil, nil,    'Test5', 'Test6'],
        [nil, 'Test9','Test8', 'Test7']
      ]
      found_attrs.map do |a|
        groups.map do |g|
          {
            :group_id=>g[:id],
            :user_attribute_id=>a[:id],
            :value=>values[g[:id]][a[:id]]
          }
        end
      end.flatten.map {|r| HashResponse.new(r)}
    end
    mock_sdk
  end

  it "executes `attribute get_group_value` command successfully with ids" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Attribute::GetGroupValue.new("1","3",options)

    command.instance_variable_set(:@sdk, mock_sdk())

    command.execute(output: output)

    expect(output.string).to eq("Test2\n")
  end

  it "executes `attribute get_group_value` command successfully with names" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Attribute::GetGroupValue.new("group_3","attribute_2",options)

    command.instance_variable_set(:@sdk, mock_sdk())

    command.execute(output: output)

    expect(output.string).to eq("Test8\n")
  end
end
