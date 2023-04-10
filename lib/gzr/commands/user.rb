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
    class User < SubCommandBase

      namespace :user

      desc 'enable USER_ID', 'Enable the user given by user_id'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def enable(user_id)
        if options[:help]
          invoke :help, ['enable']
        else
          require_relative 'user/enable'
          Gzr::Commands::User::Enable.new(user_id,options).execute
        end
      end

      desc 'disable USER_ID', 'Disable the user given by user_id'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def disable(user_id)
        if options[:help]
          invoke :help, ['disable']
        else
          require_relative 'user/disable'
          Gzr::Commands::User::Disable.new(user_id,options).execute
        end
      end

      desc 'delete USER_ID', 'Delete the user given by user_id'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def delete(user_id)
        if options[:help]
          invoke :help, ['delete']
        else
          require_relative 'user/delete'
          Gzr::Commands::User::Delete.new(user_id,options).execute
        end
      end

      desc 'cat USER_ID', 'Output json information about a user to screen or file'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :fields, type: :string,
                           desc: 'Fields to display'
      method_option :dir,  type: :string,
                           desc: 'Directory to store output file'
      def cat(user_id)
        if options[:help]
          invoke :help, ['cat']
        else
          require_relative 'user/cat'
          Gzr::Commands::User::Cat.new(user_id,options).execute
        end
      end

      desc 'me', 'Show information for the current user'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :fields, type: :string, default: 'id,email,last_name,first_name,personal_folder_id,home_folder_id',
                           desc: 'Fields to display'
      method_option :plain, type: :boolean, default: false,
                           desc: 'print without any extra formatting'
      method_option :csv, type: :boolean, default: false,
                           desc: 'output in csv format per RFC4180'
      def me(*)
        if options[:help]
          invoke :help, ['me']
        else
          require_relative 'user/me'
          Gzr::Commands::User::Me.new(options).execute
        end
      end

      desc 'ls', 'list all users'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :fields, type: :string, default: 'id,email,last_name,first_name,personal_folder_id,home_folder_id',
                           desc: 'Fields to display'
      method_option :"last-login", type: :boolean, default: false,
                           desc: 'Include the time of the most recent login'
      method_option :plain, type: :boolean, default: false,
                           desc: 'print without any extra formatting'
      method_option :csv, type: :boolean, default: false,
                           desc: 'output in csv format per RFC4180'
      def ls(*)
        if options[:help]
          invoke :help, ['ls']
        else
          require_relative 'user/ls'
          Gzr::Commands::User::Ls.new(options).execute
        end
      end
    end
  end
end
