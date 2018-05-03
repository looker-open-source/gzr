# frozen_string_literal: true

require 'thor'

module Lkr
  module Commands
    class User < Thor

      namespace :user

      desc 'me', 'Command description...'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def me(*)
        if options[:help]
          invoke :help, ['me']
        else
          require_relative 'user/me'
          Lkr::Commands::User::Me.new(options).execute
        end
      end

      desc 'ls', 'Command description...'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
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
