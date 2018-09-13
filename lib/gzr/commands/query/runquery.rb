# frozen_string_literal: true

require_relative '../../command'
require 'json'

module Gzr
  module Commands
    class Query
      class RunQuery < Gzr::Command
        def initialize(query_def,options)
          super()
          @query_def = query_def
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          unless @query_def
            raise Gzr::CLI::Error, "No query specified. A query id, query slug, or a query in json formation must be specified."
          end

          case @options[:format]
          when 'png','jpg','xlsx'
            raise Gzr::CLI::Error, "Output file must be specified with '--file=filename' when using '--format=#{@options[:format]}" unless @options[:file]
          when 'json', 'json_detail', 'csv', 'txt', 'html', 'md', 'sql'
            # these formats can be output to stdout
          else
            raise Gzr::CLI::Error, "'--format=#{@options[:format]}' not understood. The format must be one of json,json_detail,csv,txt,html,md,xlsx,sql,png,jpg"
          end

          case @query_def
          when /^[0-9]+$/
            query_id = @query_def.to_i
          when /^[A-Za-z0-9]+$/
            query_slug = @query_def
          else
            begin
              query_hash = JSON.parse(@query_def,{:symbolize_names => true})
            rescue JSON::ParserError => e
              raise Gzr::CLI::Error, "The query specification is not a valid id, slug, or json document"
            end
          end

          f = File.open(@options[:file], "w") if @options[:file]
          with_session do
            if query_id || query_slug then
              begin
                @sdk.query(query_id)
              rescue LookerSDK::NotFound => e
                raise Gzr::CLI::Error, "Query with the id #{query_id} not found"
              end if query_id

              begin
                query_id = @sdk.query_for_slug(query_slug, { :fields => 'id' }).id.to_i
              rescue LookerSDK::NotFound => e
                raise Gzr::CLI::Error, "Query with the slug #{query_slug} not found"
              end if query_slug

              begin
                @sdk.run_query(query_id,@options[:format]) { |data,progress| (f || output).write(data) }
              rescue LookerSDK::Error => e
                say_error "Error in run_query(#{query_id},#{@options[:format]})})"
                say_error e.message
                raise
              end
            else
              begin
                @sdk.run_inline_query(@options[:format],query_hash) { |data,progress| (f || output).write(data) } 
              rescue LookerSDK::Error => e
                say_error "Error in run_inline_query(#{@options[:format]},#{JSON.pretty_generate(query_hash)})"
                say_error e.message
                raise
              end
            end
          end
        ensure
          f.close if f
        end
      end
    end
  end
end
