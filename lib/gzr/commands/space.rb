# The MIT License (MIT)

# Copyright (c) 2018 Mike DeAngelo Looker Data Sciences, Inc.

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

require_relative 'subcommandbase'

module Gzr
  module Commands
    class Space < SubCommandBase

      namespace :space

      desc 'create NAME PARENT_SPACE', 'Command description...'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :plain, type: :boolean,
                           desc: 'Provide minimal response information'
      def create(name, parent_space)
        if options[:help]
          invoke :help, ['create']
        else
          require_relative 'space/create'
          Gzr::Commands::Space::Create.new(name, parent_space, options).execute
        end
      end

      desc 'top', 'Retrieve the top level (or root) spaces'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :fields, type: :string, default: 'id,name,is_shared_root,is_users_root,is_embed_shared_root,is_embed_users_root',
                           desc: 'Fields to display'
      method_option :plain, type: :boolean, default: false,
                           desc: 'print without any extra formatting'
      method_option :csv, type: :boolean, default: false,
                           desc: 'output in csv format per RFC4180'
      def top(*)
        if options[:help]
          invoke :help, ['top']
        else
          require_relative 'space/top'
          Gzr::Commands::Space::Top.new(options).execute
        end
      end

      desc 'export SPACE_ID', 'Export a space, including all child looks, dashboards, and spaces.'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :dir, type: :string, default: '.',
                           desc: 'Directory to store output tree'
      method_option :tar, type: :string,
                           desc: 'Tar file to store output'
      method_option :tgz, type: :string,
                           desc: 'TarGZ file to store output'
      method_option :zip, type: :string,
                           desc: 'Zip file to store output'
      def export(starting_space)
        if options[:help]
          invoke :help, ['export']
        else
          require_relative 'space/export'
          Gzr::Commands::Space::Export.new(starting_space,options).execute
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
          Gzr::Commands::Space::Tree.new(starting_space,options).execute
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
          Gzr::Commands::Space::Cat.new(space_id,options).execute
        end
      end

      desc 'ls FILTER_SPEC', 'list the contents of a space given by space name, space_id, ~ for the current user\'s default space, or ~name / ~number for the home space of a user'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :fields, type: :string, default: 'parent_id,id,name,looks(id,title),dashboards(id,title)',
                           desc: 'Fields to display'
      method_option :plain, type: :boolean, default: false,
                           desc: 'print without any extra formatting'
      method_option :csv, type: :boolean, default: false,
                           desc: 'output in csv format per RFC4180'
      def ls(filter_spec=nil)
        if options[:help]
          invoke :help, ['ls']
        else
          require_relative 'space/ls'
          Gzr::Commands::Space::Ls.new(filter_spec,options).execute
        end
      end

      desc 'rm SPACE_ID', 'Delete a space. The space must be empty or the --force flag specified to deleted subspaces, dashboards, and looks.'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def rm(space_id)
        if options[:help]
          invoke :help, ['rm']
        else
          require_relative 'space/rm'
          Gzr::Commands::Space::Rm.new(space_id,options).execute
        end
      end
    end
  end
end
