# frozen_string_literal: true

require_relative 'subcommandbase'

module Gzr
  module Commands
    class Plan < SubCommandBase

      namespace :plan

      desc 'failures', 'Report all plans that failed in their most recent run attempt'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :plain, type: :boolean, default: false,
                           desc: 'print without any extra formatting'
      method_option :csv, type: :boolean, default: false,
                           desc: 'output in csv format per RFC4180'
      def failures(*)
        if options[:help]
          invoke :help, ['failures']
        else
          require_relative 'plan/failures'
          Gzr::Commands::Plan::Failures.new(options).execute
        end
      end

      desc 'runit PLAN_ID', 'Execute a saved plan immediately'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def runit(plan_id)
        if options[:help]
          invoke :help, ['runit']
        else
          require_relative 'plan/run'
          Gzr::Commands::Plan::RunIt.new(plan_id,options).execute
        end
      end

      desc 'disable PLAN_ID', 'Disable the specified plan'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def disable(plan_id)
        if options[:help]
          invoke :help, ['disable']
        else
          require_relative 'plan/disable'
          Gzr::Commands::Plan::Disable.new(plan_id,options).execute
        end
      end

      desc 'enable PLAN_ID', 'Enable the specified plan'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def enable(plan_id)
        if options[:help]
          invoke :help, ['enable']
        else
          require_relative 'plan/enable'
          Gzr::Commands::Plan::Enable.new(plan_id,options).execute
        end
      end

      desc 'rm PLAN_ID', 'Delete a scheduled plan'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def rm(plan_id)
        if options[:help]
          invoke :help, ['rm']
        else
          require_relative 'plan/rm'
          Gzr::Commands::Plan::Rm.new(plan_id, options).execute
        end
      end

      desc 'import PLAN_FILE OBJ_TYPE OBJ_ID', 'Import a plan from a file'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :plain, type: :boolean,
                           desc: 'Provide minimal response information'
      method_option :enable, type: :boolean,
                           desc: 'Enable the plan on import'
      method_option :disable, type: :boolean,
                           desc: 'Disable the plan on import'
      def import(plan_file, obj_type, id )
        if options[:help]
          invoke :help, ['import']
        else
          require_relative 'plan/import'
          Gzr::Commands::Plan::Import.new(plan_file, obj_type, id, options).execute
        end
      end

      desc 'cat PLAN_ID', 'Output the JSON representation of a scheduled plan to the screen or a file'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :dir,  type: :string,
                           desc: 'Directory to get output file'
      def cat(plan_id)
        if options[:help]
          invoke :help, ['cat']
        else
          require_relative 'plan/cat'
          Gzr::Commands::Plan::Cat.new(plan_id,options).execute
        end
      end

      desc 'ls', 'List the scheduled plans on a server'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :fields, type: :string, default: 'id,enabled,name,user(id,display_name),look_id,dashboard_id,lookml_dashboard_id',
                           desc: 'Fields to display'
      method_option :disabled, type: :boolean,
                           desc: 'Retrieve disable plans'
      method_option :plain, type: :boolean, default: false,
                           desc: 'print without any extra formatting'
      method_option :csv, type: :boolean, default: false,
                           desc: 'output in csv format per RFC4180'
      def ls(*)
        if options[:help]
          invoke :help, ['ls']
        else
          require_relative 'plan/ls'
          Gzr::Commands::Plan::Ls.new(options).execute
        end
      end
    end
  end
end
