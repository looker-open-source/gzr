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

# frozen_string_literal: true

require 'thor'

module Gzr
  module Commands
    class Attribute < Thor

      namespace :attribute

      desc 'set_group_values', 'Command description...'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def set_group_values(*)
        if options[:help]
          invoke :help, ['set_group_values']
        else
          require_relative 'attribute/set_group_values'
          Gzr::Commands::Attribute::SetGroupValues.new(options).execute
        end
      end

      desc 'get_group_values', 'Command description...'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def get_group_values(*)
        if options[:help]
          invoke :help, ['get_group_values']
        else
          require_relative 'attribute/get_group_values'
          Gzr::Commands::Attribute::GetGroupValues.new(options).execute
        end
      end

      desc 'rm', 'Command description...'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def rm(*)
        if options[:help]
          invoke :help, ['rm']
        else
          require_relative 'attribute/rm'
          Gzr::Commands::Attribute::Rm.new(options).execute
        end
      end

      desc 'import FILE', 'Import a user attribute from a file'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :plain, type: :boolean,
                           desc: 'Provide minimal response information'
      method_option :force,  type: :boolean,
                           desc: 'If the user attribute already exists, modify it'
      def import(file)
        if options[:help]
          invoke :help, ['import']
        else
          require_relative 'attribute/import'
          Gzr::Commands::Attribute::Import.new(file,options).execute
        end
      end

      desc 'create', 'Command description...'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def create(*)
        if options[:help]
          invoke :help, ['create']
        else
          require_relative 'attribute/create'
          Gzr::Commands::Attribute::Create.new(options).execute
        end
      end

      desc 'cat ATTR_ID', 'Output json information about an attribute to screen or file'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :fields, type: :string,
                           desc: 'Fields to display'
      method_option :dir,  type: :string,
                           desc: 'Directory to store output file'
      def cat(attribute_id)
        if options[:help]
          invoke :help, ['cat']
        else
          require_relative 'attribute/cat'
          Gzr::Commands::Attribute::Cat.new(attribute_id,options).execute
        end
      end

      desc 'ls', 'List all the defined user attributes'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :fields, type: :string, default: 'id,name,label,type,default_value',
                           desc: 'Fields to display'
      method_option :plain, type: :boolean, default: false,
                           desc: 'print without any extra formatting'
      method_option :csv, type: :boolean, default: false,
                           desc: 'output in csv format per RFC4180'
      def ls(*)
        if options[:help]
          invoke :help, ['ls']
        else
          require_relative 'attribute/ls'
          Gzr::Commands::Attribute::Ls.new(options).execute
        end
      end
    end
  end
end
