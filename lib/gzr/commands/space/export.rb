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

require_relative '../../command'
require_relative '../../modules/space'
require_relative '../../modules/look'
require_relative '../../modules/dashboard'
require_relative '../../modules/plan'
require_relative '../../modules/filehelper'
require 'pathname'
require 'stringio'
require 'zip'

module Gzr
  module Commands
    class Space
      class Export < Gzr::Command
        include Gzr::Space
        include Gzr::Look
        include Gzr::Dashboard
        include Gzr::Plan
        include Gzr::FileHelper
        def initialize(space_id, options)
          super()
          @space_id = space_id
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options[:debug]
          with_session("3.1") do
            if @options[:tar] || @options[:tgz] || @options[:zip] then
              arc_path = Pathname.new(@options[:tgz] || @options[:tar] || @options[:zip])
              arc_path = Pathname.new(File.expand_path(@options[:dir])) + arc_path unless arc_path.absolute?
              if @options[:tar] || @options[:tgz]
                f = File.open(arc_path.to_path, "wb")
                tarfile = StringIO.new(String.new,"w") unless @options[:zip]
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
                z = Zip::File.new(arc_path.to_path, Zip::File::CREATE, false, continue_on_exists_proc: true)
                begin
                  process_space(@space_id, z)
                ensure
                  z.close
                end
              end
            else
              process_space(@space_id, @options[:dir])
            end
          end
        end

        def process_space(space_id, base, rel_path = nil)
          space = query_space(space_id).to_attrs
          name = space[:name]
          name = "nil (#{space_id})" if name.nil?
          path = Pathname.new(name.gsub('/',"\u{2215}"))
          path = rel_path + path if rel_path

          write_file("Space_#{space[:id]}_#{name}.json", base, path) do |f|
            f.write JSON.pretty_generate(space.reject do |k,v|
              [:looks, :dashboards].include?(k)
            end)
          end
          space[:looks].each do |l|
            look = cat_look(l[:id])
            write_file("Look_#{look[:id]}_#{look[:title]}.json", base, path) do |f|
              f.write JSON.pretty_generate(look)
            end
          end
          space[:dashboards].each do |d|
            data = cat_dashboard(d[:id])
            write_file("Dashboard_#{data[:id]}_#{data[:title]}.json", base, path) do |f|
              f.write JSON.pretty_generate(data)
            end
          end
          space_children = query_space_children(space_id)
          space_children.each do |child_space|
            process_space(child_space[:id], base, path)
          end
        end
      end
    end
  end
end
