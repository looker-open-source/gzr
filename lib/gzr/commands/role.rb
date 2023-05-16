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

require 'thor'

module Gzr
  module Commands
    class Role < Thor

      namespace :role

      desc 'group_rm ROLE_ID GROUP_ID GROUP_ID GROUP_ID ...', 'Remove indicated groups from role'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def group_rm(role_id, *groups)
        if options[:help]
          invoke :help, ['group_rm']
        else
          require_relative 'role/group_rm'
          Gzr::Commands::Role::GroupRm.new(role_id, groups, options).execute
        end
      end

      desc 'user_rm ROLE_ID USER_ID USER_ID USER_ID ...', 'Remove indicated users from role'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def user_rm(role_id,*users)
        if options[:help]
          invoke :help, ['user_rm']
        else
          require_relative 'role/user_rm'
          Gzr::Commands::Role::UserRm.new(role_id,users,options).execute
        end
      end

      desc 'group_add ROLE_ID GROUP_ID GROUP_ID GROUP_ID ...', 'Add indicated groups to role'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def group_add(role_id,*groups)
        if options[:help]
          invoke :help, ['group_add']
        else
          require_relative 'role/group_add'
          Gzr::Commands::Role::GroupAdd.new(role_id, groups, options).execute
        end
      end

      desc 'user_add ROLE_ID USER_ID USER_ID USER_ID ...', 'Add indicated users to role'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def user_add(role_id,*users)
        if options[:help]
          invoke :help, ['user_add']
        else
          require_relative 'role/user_add'
          Gzr::Commands::Role::UserAdd.new(role_id,users,options).execute
        end
      end

      desc 'group_ls ROLE_ID', 'List the groups assigned to a role'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :fields, type: :string, default: 'id,name,external_group_id',
                           desc: 'Fields to display'
      method_option :plain, type: :boolean, default: false,
                           desc: 'print without any extra formatting'
      method_option :csv, type: :boolean, default: false,
                           desc: 'output in csv format per RFC4180'
      def group_ls(role_id)
        if options[:help]
          invoke :help, ['group_ls']
        else
          require_relative 'role/group_ls'
          Gzr::Commands::Role::GroupLs.new(role_id,options).execute
        end
      end

      desc 'user_ls ROLE_ID', 'List the users assigned to a role'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :fields, type: :string, default: 'id,first_name,last_name,email',
                           desc: 'Fields to display'
      method_option :plain, type: :boolean, default: false,
                           desc: 'print without any extra formatting'
      method_option :csv, type: :boolean, default: false,
                           desc: 'output in csv format per RFC4180'
      method_option :all_users, type: :boolean, default: false,
                           desc: 'Show users with this role through a group membership'
      def user_ls(role_id)
        if options[:help]
          invoke :help, ['user_ls']
        else
          require_relative 'role/user_ls'
          Gzr::Commands::Role::UserLs.new(role_id,options).execute
        end
      end

      desc 'rm ROLE_ID', 'Delete a role'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def rm(role_id)
        if options[:help]
          invoke :help, ['rm']
        else
          require_relative 'role/rm'
          Gzr::Commands::Role::Rm.new(role_id,options).execute
        end
      end

      desc 'cat ROLE_ID', 'Output the JSON representation of a role to screen/file'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :dir,  type: :string,
                           desc: 'Directory to get output file'
      method_option :trim, type: :boolean,
                           desc: 'Trim output to minimal set of fields for later import'
      def cat(role_id)
        if options[:help]
          invoke :help, ['cat']
        else
          require_relative 'role/cat'
          Gzr::Commands::Role::Cat.new(role_id,options).execute
        end
      end

      desc 'ls', 'Display all roles'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :fields, type: :string, default: 'id,name,permission_set(id,name,permissions),model_set(id,name,models)',
                           desc: 'Fields to display'
      method_option :plain, type: :boolean, default: false,
                           desc: 'print without any extra formatting'
      method_option :csv, type: :boolean, default: false,
                           desc: 'output in csv format per RFC4180'
      def ls(*)
        if options[:help]
          invoke :help, ['ls']
        else
          require_relative 'role/ls'
          Gzr::Commands::Role::Ls.new(options).execute
        end
      end

      desc 'create ROLE_NAME PERMISSION_SET_ID MODEL_SET_ID', "Create new role with the given permission and model sets"
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :plain, type: :boolean, default: false,
                           desc: 'print without any extra formatting'

      def create(name, pset, mset)
        if options[:help]
          invoke :help, ['create']
        else
          require_relative 'role/create'
          Gzr::Commands::Role::Create.new(name, pset, mset, options).execute
        end
      end

    end
  end
end
