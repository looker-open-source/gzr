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
    class Dashboard < SubCommandBase

      namespace :dashboard

      desc 'mv DASHBOARD_ID TARGET_SPACE_ID', 'Move a dashboard to the given space'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :force,  type: :boolean,
                           desc: 'Overwrite a dashboard with the same name in the target space'
      def mv(dashboard_id, target_space_id)
        if options[:help]
          invoke :help, ['mv']
        else
          require_relative 'dashboard/mv'
          Gzr::Commands::Dashboard::Mv.new(dashboard_id, target_space_id, options).execute
        end
      end

      desc 'cat DASHBOARD_ID', 'Output the JSON representation of a dashboard to the screen or a file'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :dir,  type: :string,
                           desc: 'Directory to store output file'
      method_option :plans,  type: :boolean,
                           desc: 'Include scheduled plans'
      method_option :transform,  type: :string,
                           desc: 'Fully-qualified path to a JSON file describing the transformations to apply'
      def cat(dashboard_id)
        if options[:help]
          invoke :help, ['cat']
        else
          require_relative 'dashboard/cat'
          Gzr::Commands::Dashboard::Cat.new(dashboard_id, options).execute
        end
      end

      desc 'import FILE DEST_SPACE_ID', 'Import a dashboard from a file'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :plain, type: :boolean,
                           desc: 'Provide minimal response information'
      method_option :force,  type: :boolean,
                           desc: 'Overwrite a dashboard with the same name/slug in the target space'
      def import(file,dest_space_id)
        if options[:help]
          invoke :help, ['import']
        else
          require_relative 'dashboard/import'
          Gzr::Commands::Dashboard::Import.new(file, dest_space_id, options).execute
        end
      end

      desc 'rm DASHBOARD_ID', 'Remove or delete the given dashboard'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :soft,  type: :boolean,
                           desc: 'Soft delete the dashboard'
      method_option :restore,  type: :boolean,
                           desc: 'Restore a soft deleted dashboard'
      def rm(id)
        if options[:help]
          invoke :help, ['rm']
        else
          require_relative 'dashboard/rm'
          Gzr::Commands::Dashboard::Rm.new(id, options).execute
        end
      end
    end
  end
end
