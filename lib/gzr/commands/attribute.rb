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

      desc 'import', 'Command description...'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def import(*)
        if options[:help]
          invoke :help, ['import']
        else
          require_relative 'attribute/import'
          Gzr::Commands::Attribute::Import.new(options).execute
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

      desc 'cat', 'Command description...'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def cat(*)
        if options[:help]
          invoke :help, ['cat']
        else
          require_relative 'attribute/cat'
          Gzr::Commands::Attribute::Cat.new(options).execute
        end
      end

      desc 'ls', 'Command description...'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
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
