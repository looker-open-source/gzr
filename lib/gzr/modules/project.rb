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

module Gzr
  module Project

    def all_projects(fields: 'id')
      begin
        @sdk.all_projects({ fields: fields }).collect { |p| p.to_attrs }
      rescue LookerSDK::NotFound => e
        return []
      rescue LookerSDK::Error => e
        say_error "Error querying all_projects(#{fields})"
        say_error e
        raise
      end
    end

    def cat_project(project_id)
      begin
        @sdk.project(project_id)&.to_attrs
      rescue LookerSDK::NotFound => e
        say_error "project(#{project_id}) not found"
        say_error e
        raise
      rescue LookerSDK::Error => e
        say_error "Error getting project(#{project_id})"
        say_error e
        raise
      end
    end

    def trim_project(data)
      data.select do |k,v|
        keys_to_keep('create_project').include? k
      end
    end

    def create_project(body)
      begin
        @sdk.create_project(body)&.to_attrs
      rescue LookerSDK::Error => e
        say_error "Error running create_project(#{JSON.pretty_generate(body)})"
        say_error e
        raise
      end
    end

    def update_project(id,body)
      begin
        @sdk.update_project(id,body)&.to_attrs
      rescue LookerSDK::NotFound => e
        say_error "update_project(#{id},#{JSON.pretty_generate(body)} not found)"
        say_error e
        raise
      rescue LookerSDK::Error => e
        say_error "Error running update_project(#{id},#{JSON.pretty_generate(body)})"
        say_error e
        raise
      end
    end

    def git_deploy_key(id)
      begin
        @sdk.git_deploy_key(id)
      rescue LookerSDK::NotFound => e
        nil
      rescue LookerSDK::Error => e
        say_error "Error running git_deploy_key(#{id})"
        say_error e
        raise
      end
    end

    def create_git_deploy_key(id)
      begin
        @sdk.create_git_deploy_key(id)
      rescue LookerSDK::NotFound => e
        nil
      rescue LookerSDK::Error => e
        say_error "Error running create_git_deploy_key(#{id})"
        say_error e
        raise
      end
    end

    def all_git_branches(proj_id)
      begin
        @sdk.all_git_branches(proj_id).collect { |b| b.to_attrs }
      rescue LookerSDK::NotFound => e
        []
      rescue LookerSDK::Error => e
        say_error "Error running all_git_branches(#{proj_id})"
        say_error e
        raise
      end
    end

    def git_branch(proj_id)
      begin
        @sdk.git_branch(proj_id).to_attrs
      rescue LookerSDK::NotFound => e
        nil
      rescue LookerSDK::Error => e
        say_error "Error running git_branch(#{proj_id})"
        say_error e
        raise
      end
    end

    def deploy_to_production(proj_id)
      begin
        @sdk.deploy_to_production(proj_id)
      rescue LookerSDK::NotFound => e
        say_error "deploy_to_production(#{proj_id}) not found"
        say_error e
        raise
      rescue LookerSDK::Error => e
        say_error "Error running deploy_to_production(#{proj_id})"
        say_error e
        raise
      end
    end

    def update_git_branch(proj_id, name)
      body = { name: name }
      begin
        @sdk.update_git_branch(proj_id, body)&.to_attrs
      rescue LookerSDK::NotFound => e
        say_error "update_git_branch(#{proj_id},#{JSON.pretty_generate(body)}) not found"
        say_error e
        raise
      rescue LookerSDK::Error => e
        say_error "Error running update_git_branch(#{proj_id},#{JSON.pretty_generate(body)})"
        say_error e
        raise
      end
    end
  end
end
