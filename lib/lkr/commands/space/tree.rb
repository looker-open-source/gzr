# frozen_string_literal: true

require_relative '../../command'
require 'tty-tree'

module Lkr
  module Commands
    class Space
      class Tree < Lkr::Command
        def initialize(options)
          super()
          @options = options
        end

        def execute(*args, input: $stdin, output: $stdout)
          say_warning("args: #{args.inspect}") if @options.debug
          say_warning("options: #{@options.inspect}") if @options.debug
          begin
            login
            space_ids = process_args(args)

            tree_data = Hash.new
            
            space_ids.each do |space_id| 
              s = query_space(space_id, "id,name,parent_id,looks(id,title),dashboards(id,title)")
              space_name = s.name
              space_name = "nil (#{s.id})" unless space_name 
              space_name = "\"#{space_name}\"" if ((space_name != space_name.strip) || (space_name.length == 0))
              space_name += " (#{space_id})" unless space_ids.length == 1
              tree_data[space_name] =
                [ recurse_spaces(s.id) ] +
                s.looks.map { |l| "(l) #{l.title}" } +
                  s.dashboards.map { |d| "(d) #{d.title}" }
            end
            tree = TTY::Tree.new(tree_data)
            output.puts tree.render
          ensure
            logout_all
          end
        end

        def recurse_spaces(space_id)
          data = query_space_children(space_id, "id,name,parent_id,looks(id,title),dashboards(id,title)")
          tree_branch = Hash.new
          data.each do |s|
            space_name = s.name
            space_name = "nil (#{s.id})" unless space_name 
            space_name = "\"#{space_name}\"" if ((space_name != space_name.strip) || (space_name.length == 0))
            tree_branch[space_name] =
              [ recurse_spaces(s.id) ] +
              s.looks.map { |l| "(l) #{l.title}" } +
              s.dashboards.map { |d| "(d) #{d.title}" }
          end
          tree_branch
        end
      end
    end
  end
end
