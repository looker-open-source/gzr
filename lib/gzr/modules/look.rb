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

    def search_looks(title, space_id=nil)
      data = nil
      begin
        req = { :title => title }
        req[:space_id] = space_id if space_id 
        data = @sdk.search_looks(req)
      rescue LookerSDK::Error => e
        say_error "Error search_looks(#{JSON.pretty_generate(req)})"
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
      existing_looks = search_looks(source_look[:title], space_id)

      if existing_looks.length > 0 then
        if @options[:force] then
          say_ok "Modifying existing Look #{source_look[:title]} in space #{space_id}"
          new_look = source_look.select do |k,v|
            (keys_to_keep('update_look') - [:space_id,:user_id,:query_id]).include? k
          end
          new_look[:query_id] = query_id
          return update_look(existing_looks.first.id,new_look)
        else
          raise Gzr::Error, "Look #{source_look[:title]} already exists in space #{space_id}\nUse --force if you want to overwrite it"
        end
      else
        new_look = source_look.select do |k,v|
          (keys_to_keep('create_look') - [:space_id,:user_id,:query_id]).include? k
        end
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
  end
end
