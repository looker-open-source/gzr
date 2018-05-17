# frozen_string_literal: true

require 'rubygems/package'

module Lkr
  module FileHelper
    def write_file(file_name=nil,base_dir=nil,path=nil,output=$stdout)
      f = nil
      if base_dir.kind_of? Gem::Package::TarWriter then
        if path then
          @archived_paths ||= Array.new
          base_dir.mkdir(path.to_path, 0755) unless @archived_paths.include?(path.to_path)
          @archived_paths << path.to_path
        end
        fn = Pathname.new(file_name)
        fn = path + fn if path
        base_dir.add_file(fn.to_path, 0644) do |tf|
          yield tf
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
        file = Pathname.new(file_name) if file_name
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