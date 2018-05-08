# frozen_string_literal: true

require 'thor'

module Lkr
  module Commands
    class Space < Thor

      namespace :space

      desc 'top', 'Retrieve the top level (or root) spaces'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def top(*)
        if options[:help]
          invoke :help, ['top']
        else
          require_relative 'space/top'
          Lkr::Commands::Space::Top.new(options).execute
        end
      end

      desc 'export', 'Export a space, including all child looks, dashboards, and spaces.'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :dir, type: :string, default: '.',
                           desc: 'Directory to store output tree'
      method_option :tar, type: :string,
                           desc: 'Tar file to store output'
      method_option :tgz, type: :string,
                           desc: 'TarGZ file to store output'
      def export(starting_space)
        if options[:help]
          invoke :help, ['export']
        else
          require_relative 'space/export'
          Lkr::Commands::Space::Export.new(starting_space,options).execute
        end
      end

      desc 'tree STARTING_SPACE', 'Display the dashbaords, looks, and subspaces or a space in a tree format'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def tree(starting_space)
        if options[:help]
          invoke :help, ['tree']
        else
          require_relative 'space/tree'
          Lkr::Commands::Space::Tree.new(starting_space,options).execute
        end
      end

      desc 'cat SPACE_ID', 'Output the JSON representation of a space to the screen or a file'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :dir,  type: :string,
                           desc: 'Directory to get output file'
      def cat(space_id)
        if options[:help]
          invoke :help, ['cat']
        else
          require_relative 'space/cat'
          Lkr::Commands::Space::Cat.new(space_id,options).execute
        end
      end

      desc 'ls FILTER_SPEC', 'list the contents of a space given by space name, space_id, ~ for the current user\'s default space, or ~name / ~number for the home space of a user'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :fields, type: :string, default: 'parent_id,id,name,looks(id,title),dashboards(id,title)',
                           desc: 'Fields to display'
      method_option :plain, type: :boolean, default: false,
                           desc: 'print without any extra formatting'
      def ls(filter_spec=nil)
        if options[:help]
          invoke :help, ['ls']
        else
          require_relative 'space/ls'
          Lkr::Commands::Space::Ls.new(filter_spec,options).execute
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
