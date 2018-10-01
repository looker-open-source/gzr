# frozen_string_literal: true

require_relative '../../command'
require_relative '../../modules/space'
require_relative '../../modules/look'
require_relative '../../modules/dashboard'
require_relative '../../modules/filehelper'
require 'pathname'
require 'stringio'

module Gzr
  module Commands
    class Space
      class Export < Gzr::Command
        include Gzr::Space
        include Gzr::Look
        include Gzr::Dashboard
        include Gzr::FileHelper
        def initialize(space_id, options)
          super()
          @space_id = space_id
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options[:debug]
          with_session("3.1") do
            if @options[:tar] || @options[:tgz] then
              arc_path = Pathname.new(@options[:tgz] || @options[:tar])
              arc_path = Pathname.new(File.expand_path(@options[:dir])) + arc_path unless arc_path.absolute?
              f = File.open(arc_path.to_path, "wb")
              tarfile = StringIO.new(String.new,"w")
              begin
                tw = Gem::Package::TarWriter.new(tarfile)
                process_space(@space_id, tw)
                tw.flush
                tarfile.rewind
                if @options[:tgz]
                  gzw = Zlib::GzipWriter.new(f)
                  gzw.write tarfile.string
                  gzw.close
                else
                  f.write tarfile.string
                end
              ensure
                f.close
                tarfile.close
              end
            else
              process_space(@space_id, @options[:dir])
            end
          end
        end

        def process_space(space_id, base, rel_path = nil)
          space = query_space(space_id)
          path = Pathname.new(space.name.gsub('/',"\u{2215}"))
          path = rel_path + path if rel_path

          write_file("Space_#{space.id}_#{space.name}.json", base, path) do |f|
            f.write JSON.pretty_generate(space.to_attrs.reject do |k,v|
              [:looks, :dashboards].include?(k)
            end)
          end
          space.looks.each do |l|
            look = query_look(l.id)
            write_file("Look_#{look.id}_#{look.title}.json", base, path) do |f|
              f.write JSON.pretty_generate(look.to_attrs) 
            end
          end
          space.dashboards.each do |d|
            data = query_dashboard(d.id)
            data.to_attrs()[:dashboard_elements].each_index do |i|
              element = data[:dashboard_elements][i]
              if element[:merge_result_id]
                merge_result = merge_query(element[:merge_result_id])
                merge_result[:source_queries].each_index do |j|
                  source_query = merge_result[:source_queries][j]
                  merge_result[:source_queries][j][:query] = query(source_query[:query_id])
                end
                data[:dashboard_elements][i][:merge_result] = merge_result
              end
            end
            write_file("Dashboard_#{data.id}_#{data.title}.json", base, path) do |f|
              f.write JSON.pretty_generate(data.to_attrs)
            end
          end
          space_children = query_space_children(space_id)
          space_children.each do |child_space|
            process_space(child_space.id, base, path)
          end
        end
      end
    end
  end
end
