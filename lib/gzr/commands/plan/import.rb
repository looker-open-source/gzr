# frozen_string_literal: true

require_relative '../../command'
require_relative '../../modules/plan'
require_relative '../../modules/user'
require_relative '../../modules/filehelper'

module Gzr
  module Commands
    class Plan
      class Import < Gzr::Command
        include Gzr::Plan
        include Gzr::User
        include Gzr::FileHelper
        def initialize(plan_file, obj_type, obj_id, options)
          super()
          @plan_file = plan_file
          @obj_type = obj_type
          @obj_id = obj_id
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options[:debug]
          with_session do

            @me ||= query_me("id")
            
            read_file(@plan_file) do |data|
              case @obj_type
              when /dashboard/i
                upsert_plan_for_dashboard(@obj_id,@me.id,data)
              when /look/i
                upsert_plan_for_look(@obj_id,@me.id,data)
              else
                raise Gzr::CLI::Error, "Invalid type '#{obj_type}', valid types are look and dashboard"
              end
            end
          end
        end
      end
    end
  end
end
