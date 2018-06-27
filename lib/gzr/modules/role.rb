# frozen_string_literal: true

module Gzr
  module Role
    def query_all_roles(fields=nil)
      req = Hash.new
      req[:fields] = fields if fields
      data = Array.new
      begin
        data = @sdk.all_roles(req)
      rescue LookerSDK::NotFound => e
        # do nothing
      rescue LookerSDK::ClientError => e
        say_error "Unable to get all_roles(#{JSON.pretty_generate(req)})"
        say_error e.message
        say_error e.errors if e.errors
        raise
      end
      data
    end
    def query_role(role_id)
      data = nil
      begin
        data = @sdk.role(role_id)
      rescue LookerSDK::NotFound => e
        # do nothing
      rescue LookerSDK::ClientError => e
        say_error "Unable to get role(#{role_id})"
        say_error e.message
        say_error e.errors if e.errors
        raise
      end
      data
    end
    def delete_role(role_id)
      data = nil
      begin
        data = @sdk.delete_role(role_id)
      rescue LookerSDK::NotFound => e
        # do nothing
      rescue LookerSDK::ClientError => e
        say_error "Unable to delete_role(#{role_id})"
        say_error e.message
        say_error e.errors if e.errors
        raise
      end
      data
    end
    def query_role_groups(role_id,fields=nil)
      req = Hash.new
      req[:fields] = fields if fields
      data = Array.new
      begin
        data = @sdk.role_groups(role_id, req)
      rescue LookerSDK::NotFound => e
        # do nothing
      rescue LookerSDK::ClientError => e
        say_error "Unable to get role_groups(#{role_id},#{JSON.pretty_generate(req)})"
        say_error e.message
        say_error e.errors if e.errors
        raise
      end
      data
    end
    def query_role_users(role_id,fields=nil,direct_association_only=true)
      req = Hash.new
      req[:fields] = fields if fields
      req[:direct_association_only] = direct_association_only
      data = Array.new
      begin
        data = @sdk.role_users(role_id, req)
      rescue LookerSDK::NotFound => e
        # do nothing
      rescue LookerSDK::ClientError => e
        say_error "Unable to get role_users(#{role_id},#{JSON.pretty_generate(req)})"
        say_error e.message
        say_error e.errors if e.errors
        raise
      end
      data
    end
  end
end
