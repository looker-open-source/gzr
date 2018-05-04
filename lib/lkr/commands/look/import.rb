# frozen_string_literal: true

require_relative '../../command'

module Lkr
  module Commands
    class Look
      class Import < Lkr::Command
        def initialize(file, dest_space_id, options)
          super()
          @file = file
          @dest_space_id = dest_space_id
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options.debug
          begin
            login
            read_file(@file) do |data|
              existing_looks = search_looks(data[:title], @dest_space_id)

              if existing_looks.length > 0 then
                if @options[:force] then
                  say_ok "Deleting and recreating Look #{data[:title]} in space #{@dest_space_id}"
                  delete_look(existing_looks.first.id)
                else
                  say_error "Look #{data[:title]} already exists in space #{@dest_space_id}"
                  return nil
                end
              end

              new_query = data[:query].select do |k,v|
                keys_to_keep('create_query').include? k
              end

              new_look = data.select do |k,v|
                keys_to_keep('create_look').include? k
              end
              new_look[:query_id] = create_query(new_query).to_attrs[:id]
              new_look[:user_id] = query_me("id").to_attrs[:id]
              new_look[:space_id] = @dest_space_id

              create_look(new_look).to_attrs
            end
          ensure
            logout_all
          end
        end
      end
    end
  end
end
