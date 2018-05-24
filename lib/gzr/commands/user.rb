# frozen_string_literal: true

require_relative 'subcommandbase'

module Gzr
  module Commands
    class User < SubCommandBase

      namespace :user

      desc 'me', 'Show information for the current user'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :fields, type: :string, default: 'id,email,last_name,first_name,personal_space_id,home_space_id',
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
      method_option :fields, type: :string, default: 'id,email,last_name,first_name,personal_space_id,home_space_id',
                           desc: 'Fields to display'
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
