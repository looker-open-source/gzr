# frozen_string_literal: true

require_relative 'subcommandbase'

module Gzr
  module Commands
    class Group < SubCommandBase

      namespace :group

      desc 'member_users GROUP_ID', 'List the users that are members of the given group'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :fields, type: :string, default: 'id,email,last_name,first_name,personal_space_id,home_space_id',
                           desc: 'Fields to display'
      method_option :plain, type: :boolean, default: false,
                           desc: 'print without any extra formatting'
      method_option :csv, type: :boolean, default: false,
                           desc: 'output in csv format per RFC4180'
      def member_users(group_id)
        if options[:help]
          invoke :help, ['member_users']
        else
          require_relative 'group/member_users'
          Gzr::Commands::Group::MemberUsers.new(group_id,options).execute
        end
      end

      desc 'member_groups GROUP_ID', 'List the groups that are members of the given group'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :fields, type: :string, default: 'id,name,user_count,contains_current_user,externally_managed,external_group_id',
                           desc: 'Fields to display'
      method_option :plain, type: :boolean, default: false,
                           desc: 'print without any extra formatting'
      method_option :csv, type: :boolean, default: false,
                           desc: 'output in csv format per RFC4180'
      def member_groups(group_id)
        if options[:help]
          invoke :help, ['member_groups']
        else
          require_relative 'group/member_groups'
          Gzr::Commands::Group::MemberGroups.new(group_id,options).execute
        end
      end

      desc 'ls', 'List the groups that are defined on this server'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :fields, type: :string, default: 'id,name,user_count,contains_current_user,externally_managed,external_group_id',
                           desc: 'Fields to display'
      method_option :plain, type: :boolean, default: false,
                           desc: 'print without any extra formatting'
      method_option :csv, type: :boolean, default: false,
                           desc: 'output in csv format per RFC4180'
      def ls(*)
        if options[:help]
          invoke :help, ['ls']
        else
          require_relative 'group/ls'
          Gzr::Commands::Group::Ls.new(options).execute
        end
      end
    end
  end
end
