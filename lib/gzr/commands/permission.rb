# The MIT License (MIT)

# Copyright (c) 2023 Mike DeAngelo Google, Inc.

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
    class Permission < SubCommandBase

      require_relative 'permission/set'
      register Gzr::Commands::Permission::Set, 'set', 'set [SUBCOMMAND]', 'Commands pertaining to permission sets'

      namespace :permission

      desc 'ls', 'List all available permissions'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :plain, type: :boolean, default: false,
                           desc: 'print without any extra formatting'
      method_option :csv, type: :boolean, default: false,
                           desc: 'output in csv format per RFC4180'
      def ls(*)
        if options[:help]
          invoke :help, ['ls']
        else
          require_relative 'permission/ls'
          Gzr::Commands::Permission::Ls.new(options).execute
        end
      end

      desc 'tree', 'List all available permissions in a tree'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def tree(*)
        if options[:help]
          invoke :help, ['tree']
        else
          require_relative 'permission/tree'
          Gzr::Commands::Permission::Tree.new(options).execute
        end
      end

    end
  end
end
