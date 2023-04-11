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

module Gzr
  module Folder
    def self.included klass
      require_relative '../modules/user'
      klass.class_eval do
        include Gzr::User
      end
    end

    def create_folder(name, parent_id)
      data = nil
      begin
        req = {:name => name, :parent_id => parent_id}
        data = @sdk.create_folder(req)
      rescue LookerSDK::Error => e
        say_error "Error creating folder(#{JSON.pretty_generate(req)})"
        say_error e.message
        raise
      end
      data
    end

    def search_folders(name,fields=nil)
      data = nil
      begin
        req = {:name => name}
        req[:fields] = fields if fields
        data = @sdk.search_folders(req)
      rescue LookerSDK::Error => e
        say_error "Error querying search_folders(#{JSON.pretty_generate(req)})"
        say_error e.message
        raise
      end
      data
    end

    def query_folder(id,fields=nil)
      data = nil
      begin
        req = {}
        req[:fields] = fields if fields 
        data = @sdk.folder(id, req)
      rescue LookerSDK::NotFound
        return nil
      rescue LookerSDK::Error => e
        say_error "Error querying folder(#{id},#{JSON.pretty_generate(req)})"
        say_error e.message
        raise
      end
      data
    end

    def process_args(args)
      folder_ids = []

      begin
        user = query_me("home_folder_id")
        folder_ids << user.home_folder_id
      end unless args && args.length > 0 && !(args[0].nil?)

      if args[0] == 'lookml'
        folder_ids << 'lookml'
      elsif args[0] =~ /^[0-9]+$/ then
        folder_ids << args[0].to_i
      elsif args[0] == "~" then
        user = query_me("personal_folder_id")
        folder_ids << user.personal_folder_id
      elsif args[0] =~ /^~[0-9]+$/ then
        user = query_user(args[0].sub('~',''), "personal_folder_id")
        folder_ids << user.personal_folder_id
      elsif args[0] =~ /^~.+@.+$/ then
        search_results = search_users( { :email=>args[0].sub('~','') },"personal_folder_id" )
        folder_ids += search_results.map { |r| r.personal_folder_id }
      elsif args[0] =~ /^~.+$/ then
        first_name, last_name = args[0].sub('~','').split(' ')
        search_results = search_users( { :first_name=>first_name, :last_name=>last_name },"personal_folder_id" )
        folder_ids += search_results.map { |r| r.personal_folder_id }
      else
        search_results = search_folders(args[0],"id")
        folder_ids += search_results.map { |r| r.id }

        # The built in Shared folder is only availabe by
        # searching for Home. https://github.com/looker/helltool/issues/34994
        if args[0] == 'Shared' then
          search_results = search_folders('Home',"id,is_shared_root")
          folder_ids += search_results.select { |r| r.is_shared_root }.map { |r| r.id }
        end
      end if args && args.length > 0 && !args[0].nil?

      return folder_ids
    end

    def all_folders(fields=nil)
      data = nil
      begin
        req = {}
        req[:fields] = fields if fields 
        data = @sdk.all_folders(req)
      rescue LookerSDK::Error => e
        say_error "Error querying all_folders(#{JSON.pretty_generate(req)})"
        say_error e.message
        raise
      end
      data
    end

    def query_folder_children(folder_id, fields=nil)
      data = nil
      req = {}
      req[:fields] = fields if fields
      begin
        data = @sdk.folder_children(folder_id, req)
      rescue LookerSDK::NotFound
        return nil
      rescue LookerSDK::Error => e
        say_error "Error querying folder_children(#{folder_id}, #{JSON.pretty_generate(req)})"
        say_error e.message
        raise
      end
      data
    end

    def delete_folder(folder_id)
      data = nil
      begin
        data = @sdk.delete_folder(folder_id)
      rescue LookerSDK::NotFound
        return nil
      rescue LookerSDK::Error => e
        say_error "Error deleting folder #{folder_id}"
        say_error e.message
        raise
      end
      data
    end
  end
end
