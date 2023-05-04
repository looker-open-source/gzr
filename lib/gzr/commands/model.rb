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

require_relative 'subcommandbase'

module Gzr
  module Commands
    class Model < SubCommandBase

      namespace :model

      desc 'ls', 'List the models in this server.'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :fields, type: :string, default: 'name,label,project_name',
                           desc: 'Fields to display'
      method_option :plain, type: :boolean, default: false,
                           desc: 'print without any extra formatting'
      method_option :csv, type: :boolean, default: false,
                           desc: 'output in csv format per RFC4180'
      def ls(*)
        if options[:help]
          invoke :help, ['ls']
        else
          require_relative 'model/ls'
          Gzr::Commands::Model::Ls.new(options).execute
        end
      end

      desc 'cat MODEL_ID', 'Output json information about a model to screen or file'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :dir,  type: :string,
                           desc: 'Directory to store output file'
      method_option :trim, type: :boolean,
                           desc: 'Trim output to minimal set of fields for later import'
      def cat(model_id)
        if options[:help]
          invoke :help, ['cat']
        else
          require_relative 'model/cat'
          Gzr::Commands::Model::Cat.new(model_id,options).execute
        end
      end

      desc 'import MODEL_FILE', 'Import a model configuration from a file containing json information'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def import(model_file)
        if options[:help]
          invoke :help, ['import']
        else
          require_relative 'model/import'
          Gzr::Commands::Model::Import.new(model_file,options).execute
        end
      end

    end
  end
end
