# frozen_string_literal: true

require 'thor'

module Lkr
  module Commands
    class User < Thor

      namespace :user

      desc 'user me', 'Show information for the current user'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :fields, type: :string, default: 'id,email,last_name,first_name',
                           desc: 'Fields to display'
      method_option :plain, type: :boolean, default: false,
                           desc: 'print without any extra formatting'
      def me(*)
        if options[:help]
          invoke :help, ['me']
        else
          require_relative 'user/me'
          Lkr::Commands::User::Me.new(options).execute
        end
      end

      desc 'user ls', 'list all users'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :fields, type: :string, default: 'id,email,last_name,first_name',
                           desc: 'Fields to display'
      method_option :plain, type: :boolean, default: false,
                           desc: 'print without any extra formatting'
      def ls(*)
        if options[:help]
          invoke :help, ['ls']
        else
          require_relative 'user/ls'
          Lkr::Commands::User::Ls.new(options).execute
        end
      end
    end
  end
end
