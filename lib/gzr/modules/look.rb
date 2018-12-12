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
  module Look
    def query_look(look_id)
      data = nil
      begin
        data = @sdk.look(look_id)
      rescue LookerSDK::Error => e
          say_error "Error querying look(#{look_id})"
          say_error e.message
          raise
      end
      data
    end

    def search_looks_by_slug(slug, space_id=nil)
      data = nil
      begin
        req = { :slug => slug }
        req[:space_id] = space_id if space_id 
        data = @sdk.search_looks(req)
      rescue LookerSDK::Error => e
        say_error "Error search_looks_by_slug(#{JSON.pretty_generate(req)})"
        say_error e.message
        raise
      end
      data
    end

    def search_looks_by_title(title, space_id=nil)
      data = nil
      begin
        req = { :title => title }
        req[:space_id] = space_id if space_id 
        data = @sdk.search_looks(req)
      rescue LookerSDK::Error => e
        say_error "Error search_looks_by_title(#{JSON.pretty_generate(req)})"
        say_error e.message
        raise
      end
      data
    end

    def create_look(look)
      begin
        data = @sdk.create_look(look)
      rescue LookerSDK::Error => e
        say_error "Error creating look(#{JSON.pretty_generate(look)})"
        say_error e.message
        raise
      end
      data
    end

    def update_look(id,look)
      begin
        data = @sdk.update_look(id,look)
      rescue LookerSDK::Error => e
        say_error "Error updating look(#{id},#{JSON.pretty_generate(look)})"
        say_error e.message
        raise
      end
      data
    end

    def delete_look(look_id)
      data = nil
      begin
        data = @sdk.delete_look(look_id)
      rescue LookerSDK::Error => e
        say_error "Error deleting look(#{look_id})"
        say_error e.message
        raise
      end
      data
    end

    def upsert_look(user_id, query_id, space_id, source_look)
      existing_look = search_looks_by_title(source_look[:title], space_id).fetch(0,nil)
      slug_used = search_looks_by_slug(source_look[:slug]).fetch(0,nil) if source_look[:slug]

      if slug_used then
        if existing_look then
          if !(existing_look.space_id == slug_used.space_id && existing_look.title == slug_used.title) then
            say_warning "slug #{slug_used.slug} already used for look #{slug_used.title} in space #{slug_used.space_id}"
            say_warning "look will be imported with new slug"
          end
        else
          say_warning "slug #{slug_used.slug} already used for look #{slug_used.title} in space #{slug_used.space_id}"
          say_warning "look will be imported with new slug"
        end
      end

      if existing_look then
        if @options[:force] then
          say_ok "Modifying existing Look #{source_look[:title]} in space #{space_id}"
          new_look = source_look.select do |k,v|
            (keys_to_keep('update_look') - [:space_id,:user_id,:query_id,:slug]).include? k
          end
          new_look[:slug] = source_look[:slug] unless slug_used
          new_look[:query_id] = query_id
          return update_look(existing_look.id,new_look)
        else
          raise Gzr::CLI::Error, "Look #{source_look[:title]} already exists in space #{space_id}\nUse --force if you want to overwrite it"
        end
      else
        new_look = source_look.select do |k,v|
          (keys_to_keep('create_look') - [:space_id,:user_id,:query_id,:slug]).include? k
        end
        new_look[:slug] = source_look[:slug] unless slug_used
        new_look[:query_id] = query_id
        new_look[:user_id] = user_id
        new_look[:space_id] = space_id

        return create_look(new_look)
      end
    end

    def create_fetch_query(source_query)
      new_query = source_query.select do |k,v|
        (keys_to_keep('create_query') - [:client_id]).include? k
      end 
      return create_query(new_query)
    end

    def create_merge_result(merge_result)
      new_merge_result = merge_result.select do |k,v|
        (keys_to_keep('create_merge_query') - [:client_id,:source_queries]).include? k
      end 
      new_merge_result[:source_queries] = merge_result[:source_queries].map do |query|
        new_query = {}
        new_query[:query_id] = create_fetch_query(query[:query]).id
        new_query[:name] = query[:name]
        new_query[:merge_fields] = query[:merge_fields]
        new_query
      end
      return create_merge_query(new_merge_result)
    end
  end
end
