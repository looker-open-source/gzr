# The MIT License (MIT)

# Copyright (c) 2023 Mike DeAngelo Google, Inc.

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
require_relative '../../modules/folder'
require_relative '../../modules/look'
require_relative '../../modules/dashboard'
require_relative '../../modules/plan'
require_relative '../../modules/filehelper'
require 'pathname'
require 'stringio'
require 'zip'

module Gzr
  module Commands
    class Folder
      class Export < Gzr::Command
        include Gzr::Folder
        include Gzr::Look
        include Gzr::Dashboard
        include Gzr::Plan
        include Gzr::FileHelper
        def initialize(folder_id, options)
          super()
          @folder_id = folder_id
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options[:debug]
          with_session do
            if @options[:tar] || @options[:tgz] || @options[:zip] then
              arc_path = Pathname.new(@options[:tgz] || @options[:tar] || @options[:zip])
              arc_path = Pathname.new(File.expand_path(@options[:dir])) + arc_path unless arc_path.absolute?
              if @options[:tar] || @options[:tgz]
                f = File.open(arc_path.to_path, "wb")
                tarfile = StringIO.new(String.new,"w") unless @options[:zip]
                begin
                  tw = Gem::Package::TarWriter.new(tarfile)
                  process_folder(@folder_id, tw)
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
                  process_folder(@folder_id, z)
                ensure
                  z.close
                end
              end
            else
              process_folder(@folder_id, @options[:dir])
            end
          end
        end

        def process_folder(folder_id, base, rel_path = nil)
          folder = query_folder(folder_id)
          name = folder[:name]
          name = "nil (#{folder_id})" if name.nil?
          path = Pathname.new(name.gsub('/',"\u{2215}"))
          path = rel_path + path if rel_path

          write_file("Folder_#{folder[:id]}_#{name}.json", base, path) do |f|
            f.write JSON.pretty_generate(folder.reject do |k,v|
              [:looks, :dashboards].include?(k)
            end)
          end
          folder[:looks].each do |l|
            look = cat_look(l[:id])
            look = trim_look(look) if @options[:trim]
            write_file("Look_#{look[:id]}_#{look[:title]}.json", base, path) do |f|
              f.write JSON.pretty_generate(look)
            end
          end
          folder[:dashboards].each do |d|
            data = cat_dashboard(d[:id])
            data = trim_dashboard(data) if @options[:trim]
            write_file("Dashboard_#{data[:id]}_#{data[:title]}.json", base, path) do |f|
              f.write JSON.pretty_generate(data)
            end
          end
          folder_children = query_folder_children(folder_id)
          folder_children.each do |child_folder|
            process_folder(child_folder[:id], base, path)
          end
        end
      end
    end
  end
end
