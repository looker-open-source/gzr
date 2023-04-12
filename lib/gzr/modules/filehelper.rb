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

require 'pathname'
require 'rubygems/package'
require 'stringio'

module Gzr
  module FileHelper
    def write_file(file_name=nil,base_dir=nil,path=nil,output=$stdout)
      f = nil
      if base_dir.respond_to?(:mkdir)&& (base_dir.respond_to?(:add_file) || base_dir.respond_to?(:get_output_stream)) then
        if path then
          @archived_paths ||= Array.new
          begin
            base_dir.mkdir(path.to_path, 0755) unless @archived_paths.include?(path.to_path)
          rescue Errno::EEXIST => e
            nil
          end
          @archived_paths << path.to_path
        end
        fn = Pathname.new(file_name.gsub('/',"\u{2215}"))
        fn = path + fn if path
        if base_dir.respond_to?(:add_file)
          base_dir.add_file(fn.to_path, 0644) do |tf|
            yield tf
          end
        elsif base_dir.respond_to?(:get_output_stream)
          base_dir.get_output_stream(fn.to_path, 0644) do |zf|
            yield zf
          end
        end
        return
      end

      base = Pathname.new(File.expand_path(base_dir)) if base_dir
      begin
        p = Pathname.new(path) if path
        p.descend do |path_part|
          test_dir = base + Pathname.new(path_part)
          Dir.mkdir(test_dir) unless (test_dir.exist? && test_dir.directory?)
        end if p
        file = Pathname.new(file_name.gsub('/',"\u{2215}").gsub(':','')) if file_name
        file = p + file if p
        file = base + file if base
        f = File.open(file, "wt") if file
      end if base

      return ( f || output ) unless block_given?
      begin
        yield ( f || output )
      ensure
        f.close if f
      end
      nil
    end

    def read_file(file_name)
      file = nil
      data_hash = nil
      begin
        file = (file_name.kind_of? StringIO) ? file_name : File.open(file_name)
        data_hash = JSON.parse(file.read,{:symbolize_names => true})
      ensure
        file.close if file
      end
      return (data_hash || {}) unless block_given?

      yield data_hash || {}
    end
  end
end
