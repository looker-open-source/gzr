# frozen_string_literal: true

require_relative '../../command'
require_relative '../../modules/look'
require_relative '../../modules/user'
require_relative '../../modules/filehelper'

module Lkr
  module Commands
    class Look
      class Import < Lkr::Command
        include Lkr::Look
        include Lkr::User
        include Lkr::FileHelper
        def initialize(file, dest_space_id, options)
          super()
          @file = file
          @dest_space_id = dest_space_id
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options[:debug]
          with_session do

            @me ||= query_me("id")
            
            read_file(@file) do |data|
              look = upsert_look(@me.id,create_fetch_query(data[:query]),@dest_space_id,data)
              output.puts "Imported look #{look.id}" unless @options[:plain] 
              output.puts look.id if @options[:plain] 
            end
          end
        end
      end
    end
  end
end
