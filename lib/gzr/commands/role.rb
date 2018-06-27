# frozen_string_literal: true

require 'thor'

module Gzr
  module Commands
    class Role < Thor

      namespace :role

      desc 'group_rm', 'Command description...'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def group_rm(*)
        if options[:help]
          invoke :help, ['group_rm']
        else
          require_relative 'role/group_rm'
          Gzr::Commands::Role::GroupRm.new(options).execute
        end
      end

      desc 'user_rm', 'Command description...'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def user_rm(*)
        if options[:help]
          invoke :help, ['user_rm']
        else
          require_relative 'role/user_rm'
          Gzr::Commands::Role::UserRm.new(options).execute
        end
      end

      desc 'group_add', 'Command description...'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def group_add(*)
        if options[:help]
          invoke :help, ['group_add']
        else
          require_relative 'role/group_add'
          Gzr::Commands::Role::GroupAdd.new(options).execute
        end
      end

      desc 'user_add', 'Command description...'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def user_add(*)
        if options[:help]
          invoke :help, ['user_add']
        else
          require_relative 'role/user_add'
          Gzr::Commands::Role::UserAdd.new(options).execute
        end
      end

      desc 'group_ls', 'Command description...'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def group_ls(*)
        if options[:help]
          invoke :help, ['group_ls']
        else
          require_relative 'role/group_ls'
          Gzr::Commands::Role::GroupLs.new(options).execute
        end
      end

      desc 'user_ls', 'Command description...'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def user_ls(*)
        if options[:help]
          invoke :help, ['user_ls']
        else
          require_relative 'role/user_ls'
          Gzr::Commands::Role::UserLs.new(options).execute
        end
      end

      desc 'rm', 'Command description...'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def rm(*)
        if options[:help]
          invoke :help, ['rm']
        else
          require_relative 'role/rm'
          Gzr::Commands::Role::Rm.new(options).execute
        end
      end

      desc 'cat', 'Command description...'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def cat(*)
        if options[:help]
          invoke :help, ['cat']
        else
          require_relative 'role/cat'
          Gzr::Commands::Role::Cat.new(options).execute
        end
      end

      desc 'ls', 'Command description...'
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
    end
  end
end
