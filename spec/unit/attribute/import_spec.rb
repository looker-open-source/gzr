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

require 'gzr/commands/attribute/import'

RSpec.describe Gzr::Commands::Attribute::Import do
  attrs = [
    {
      :id => 1,
      :name => "attribute_1",
      :label => "Attribute 1",
      :type => "string",
      :default_value => nil,
      :is_system => true,
      :is_permanent => nil,
      :value_is_hidden => false,
      :user_can_view => true,
      :user_can_edit => true,
      :hidden_value_domain_whitelist => nil
    }.freeze,
    {
      :id => 2,
      :name => "attribute_2",
      :label => "Attribute 2",
      :type => "number",
      :default_value => 5,
      :is_system => false,
      :is_permanent => nil,
      :value_is_hidden => false,
      :user_can_view => true,
      :user_can_edit => true,
      :hidden_value_domain_whitelist => nil
    }.freeze,
    {
      :id => 3,
      :name => "attribute_3",
      :label => "Attribute 3",
      :type => "string",
      :default_value => nil,
      :is_system => false,
      :is_permanent => nil,
      :value_is_hidden => false,
      :user_can_view => true,
      :user_can_edit => false,
      :hidden_value_domain_whitelist => nil
    }.freeze
  ]

  operations = {
    :create_user_attribute =>
    {
      :info => {
        :parameters => [
          {
            :in => "body",
            :schema => { :$ref=>"#/definitions/UserAttribute" }
          }
        ]
      }
    },
    :update_user_attribute =>
    {
      :info => {
        :parameters => [
          {
            "name": "user_attribute_id",
            "in": "path",
            "description": "Id of user attribute",
            "required": true,
            "type": "integer",
            "format": "int64"
          },
          {
            :in => "body",
            :schema => { :$ref=>"#/definitions/UserAttribute" }
          }
        ]
      }
    }
  }.freeze

  swagger = JSON.parse(<<-SWAGGER, {:symbolize_names => true}).freeze
    {
      "definitions": {
        "UserAttribute": {
          "properties": {
            "id": {
              "type": "integer",
              "format": "int64",
              "readOnly": true,
              "description": "Unique Id",
              "x-looker-nullable": false
            },
            "name": {
              "type": "string",
              "description": "Name of user attribute",
              "x-looker-nullable": true
            },
            "label": {
              "type": "string",
              "description": "Human-friendly label for user attribute",
              "x-looker-nullable": true
            },
            "type": {
              "type": "string",
              "description": "Type of user attribute",
              "x-looker-nullable": true
            },
            "default_value": {
              "type": "string",
              "description": "Default value for when no value is set on the user",
              "x-looker-nullable": true
            },
            "is_system": {
              "type": "boolean",
              "readOnly": true,
              "description": "Attribute is a system default",
              "x-looker-nullable": false
            },
            "user_can_view": {
              "type": "boolean",
              "description": "Non-admin users can see the values of their attributes and use them in filters",
              "x-looker-nullable": false
            },
            "user_can_edit": {
              "type": "boolean",
              "description": "Users can change the value of this attribute for themselves",
              "x-looker-nullable": false
            }
          },
          "x-looker-status": "stable"
        }
      }
    }
  SWAGGER

  define_method :mock_sdk do |block_hash={}|
    mock_sdk = Object.new
    mock_sdk.define_singleton_method(:authenticated?) { true }
    mock_sdk.define_singleton_method(:logout) { }
    mock_sdk.define_singleton_method(:operations) { operations }
    mock_sdk.define_singleton_method(:swagger) { swagger }
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
    mock_sdk.define_singleton_method(:create_user_attribute) do |req|
      if block_hash && block_hash[:create_user_attribute]
        block_hash[:create_user_attribute].call(id)
      end
      req[:id] = 4
      HashResponse.new(req)
    end
    mock_sdk.define_singleton_method(:update_user_attribute) do |id,req|
      if block_hash && block_hash[:update_user_attribute]
        block_hash[:update_user_attribute].call(id,req)
      end
      found = attrs.select {|a| a[:id] == id.to_i }
      return HashResponse.new(found.first.merge(req)) if found && !found.empty?
      nil
    end
    mock_sdk
  end

  it "executes `attribute import` command successfully for a new attribute" do
    output = StringIO.new
    options = {}
    command = Gzr::Commands::Attribute::Import.new(StringIO.new( <<-DOC ),options)
{
  "name": "attribute_4",
  "label": "Attribute 4",
  "type": "string",
  "default_value": null,
  "is_system": false,
  "is_permanent": null,
  "value_is_hidden": false,
  "user_can_view": true,
  "user_can_edit": true,
  "hidden_value_domain_whitelist": null,
  "can": {
    "show": true,
    "index": true,
    "create": true,
    "show_value": true,
    "update": true,
    "destroy": true,
    "set_value": true
  }
}
    DOC

    command.instance_variable_set(:@sdk, mock_sdk())

    command.execute(output: output)

    expect(output.string).to eq <<-OUT
Imported attribute attribute_4 4
    OUT
  end

  it "executes `attribute import` command successfully with an existing attribute" do
    output = StringIO.new
    options = {:force => true}
    command = Gzr::Commands::Attribute::Import.new(StringIO.new( <<-DOC ),options)
{
  "name": "attribute_3",
  "label": "New Label",
  "type": "string",
  "default_value": null,
  "is_system": false,
  "is_permanent": null,
  "value_is_hidden": false,
  "user_can_view": true,
  "user_can_edit": true,
  "hidden_value_domain_whitelist": null,
  "can": {
    "show": true,
    "index": true,
    "create": true,
    "show_value": true,
    "update": true,
    "destroy": true,
    "set_value": true
  }
}
    DOC

    command.instance_variable_set(:@sdk, mock_sdk())

    command.execute(output: output)

    expect(output.string).to eq <<-OUT
Imported attribute attribute_3 3
    OUT
  end
end
