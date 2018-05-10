# frozen_string_literal: true

require 'thor'

module Lkr
  module Commands
    class Model < Thor

      namespace :model

      desc 'ls', 'Command description...'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :fields, type: :string, default: 'name,label,project_name',
                           desc: 'Fields to display'
      method_option :plain, type: :boolean, default: false,
                           desc: 'print without any extra formatting'
      def ls(*)
        if options[:help]
          invoke :help, ['ls']
        else
          require_relative 'model/ls'
          Lkr::Commands::Model::Ls.new(options).execute
        end
      end

      def self.banner(command, namespace = nil, subcommand = false)
        "#{basename} #{subcommand_prefix} #{command.usage}"
      end

      def self.subcommand_prefix
        self.name.gsub(%r{.*::}, '').gsub(%r{^[A-Z]}) { |match| match[0].downcase }.gsub(%r{[A-Z]}) { |match| "-#{match[0].downcase}" }
      end
    end
  end
end
