# frozen_string_literal: true

require 'thor'

module Lkr
  module Commands
    class Space < Thor

      namespace :space

      desc 'export', 'Command description...'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def export(*)
        if options[:help]
          invoke :help, ['export']
        else
          require_relative 'space/export'
          Lkr::Commands::Space::Export.new(options).execute
        end
      end

      desc 'tree STARTING_SPACE', 'Command description...'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def tree(starting_space = nil)
        if options[:help]
          invoke :help, ['tree']
        else
          require_relative 'space/tree'
          Lkr::Commands::Space::Tree.new(options).execute(starting_space)
        end
      end

      desc 'cat', 'Command description...'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def cat(*)
        if options[:help]
          invoke :help, ['cat']
        else
          require_relative 'space/cat'
          Lkr::Commands::Space::Cat.new(options).execute
        end
      end

      desc 'ls FILTER_SPEC', 'Command description...'
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
          Lkr::Commands::Space::Ls.new(options).execute(filter_spec)
        end
      end
    end
  end
end
