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
      data = []
      begin
        data = @sdk.all_projects({ fields: fields })
      rescue LookerSDK::NotFound => e
        return []
      rescue LookerSDK::Error => e
        say_error "Error querying all_projects(#{fields})"
        say_error e
        raise
      end
      data
    end

    def cat_project(project_id)
      begin
        return @sdk.project(project_id)&.to_attrs
      rescue LookerSDK::NotFound => e
        return nil
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
        return @sdk.create_project(body)&.to_attrs
      rescue LookerSDK::Error => e
        say_error "Error running create_project(#{JSON.pretty_generate(body)})"
        say_error e
        raise
      end
    end

    def update_project(id,body)
      begin
        return @sdk.update_project(id,body)&.to_attrs
      rescue LookerSDK::NotFound => e
        return nil
      rescue LookerSDK::Error => e
        say_error "Error running update_project(#{id},#{JSON.pretty_generate(body)})"
        say_error e
        raise
      end
    end

    def git_deploy_key(id)
      begin
        return @sdk.git_deploy_key(id)
      rescue LookerSDK::NotFound => e
        return nil
      rescue LookerSDK::Error => e
        say_error "Error running git_deploy_key(#{id})"
        say_error e
        raise
      end
    end

    def create_git_deploy_key(id)
      begin
        return @sdk.create_git_deploy_key(id)
      rescue LookerSDK::NotFound => e
        return nil
      rescue LookerSDK::Error => e
        say_error "Error running create_git_deploy_key(#{id})"
        say_error e
        raise
      end
    end

  end
end
