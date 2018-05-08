# frozen_string_literal: true

require 'json'
require_relative '../../command'
require_relative '../../module/dashboard'
require_relative '../../module/filehelper'

module Lkr
  module Commands
    class Dashboard
      class Cat < Lkr::Command
        include Lkr::Dashboard
        include Lkr::FileHelper
        def initialize(dashboard_id,options)
          super()
          @dashboard_id = dashboard_id
          @options = options
        end

        def execute(*args, input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options[:debug]
          with_session do
            data = query_dashboard(@dashboard_id)
            write_file(@options[:dir] ? "Dashboard_#{data.id}_#{data.title}.json" : nil, @options[:dir], nil, output) do |f|
              f.puts JSON.pretty_generate(data.to_attrs)
            end
          end
        end
      end
    end
  end
end
