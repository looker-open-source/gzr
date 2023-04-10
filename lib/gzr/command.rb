# The MIT icense (MIT)

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

require 'forwardable'
require 'tty-reader'
require 'netrc'
require 'looker-sdk'
require 'faraday/multipart'

require_relative 'modules/session'

module Gzr
  class Command
    extend Forwardable
    include Gzr::Session

    def initialize
      @sdk = nil
      @access_token_stack = Array.new
      @options = Hash.new
    end

    def_delegators :command, :run

    # Execute this command
    #
    # @api public
    def execute(*)
      raise(
        NotImplementedError,
        "#{self.class}##{__method__} must be implemented"
      )
    end

    def query(query_id)
      data = nil
      begin
        data = @sdk.query(query_id)
      rescue LookerSDK::Error => e
        say_error "Error querying query(#{query_id})"
        say_error e.message
        raise
      end
      data
    end

    def create_query(query)
      begin
        data = @sdk.create_query(query)
        if !(data.respond_to?(:id))
          raise Gzr::CLI::Error, "create_query(#{JSON.pretty_generate(query)}) returned #{data.inspect}"
        end
      rescue LookerSDK::Error => e
        say_error "Error creating query(#{JSON.pretty_generate(query)})"
        say_error e.message
        raise
      end
      data
    end

    def merge_query(merge_result_id)
      data = nil
      begin
        data = @sdk.merge_query(merge_result_id)
      rescue NoMethodError => nme
        say_error "The api endpoint merge_query(#{merge_result_id}) is not implemented on this Looker instance"
      rescue LookerSDK::Error => e
        say_error "Error querying merge_query(#{merge_result_id})"
        say_error e.message
        raise
      end
      data
    end

    def create_merge_query(merge_query)
      begin
        data = @sdk.create_merge_query(merge_query)
      rescue NoMethodError => nme
        say_error "The api endpoint create_merge_query() is not implemented on this Looker instance"
        raise
      rescue LookerSDK::Error => e
        say_error "Error creating merge_query(#{JSON.pretty_generate(merge_query)})"
        say_error e.message
        raise
      end
      data
    end

    def run_inline_query(query)
      begin
        data = @sdk.run_inline_query("json",query)
      rescue LookerSDK::Error => e
        say_error "Error running inline_query(#{JSON.pretty_generate(query)})"
        say_error e.message
        raise
      end
      data
    end

    def all_color_collections()
      data = nil
      begin
        data = @sdk.all_color_collections().collect { |o| o.to_attrs if o.respond_to?(:to_attrs) }
      rescue NoMethodError => nme
        say_warning "The api endpoint all_color_collections() is not implemented on this Looker instance"
      rescue LookerSDK::NotFound => nf
        say_warning "The current user can't query all color collections"
      rescue LookerSDK::Error => e
        say_error "Error querying all_color_collections()"
        say_error e.message
        raise
      end
      data
    end

    def default_color_collection()
      return @dcc if @dcc
      data = nil
      begin
        data = @sdk.default_color_collection().to_attrs
        @dcc = data
      rescue NoMethodError => nme
        say_warning "The api endpoint default_color_collection() is not implemented on this Looker instance"
      rescue LookerSDK::NotFound => nf
        say_warning "The current user can't query the default color collection"
      rescue LookerSDK::Error => e
        say_error "Error querying default_color_collection()"
        say_error e.message
        raise
      end
      data
    end

    def color_collection(collection_id)
      data = nil
      begin
        data = @sdk.color_collection(collection_id).to_attrs
      rescue NoMethodError => nme
        say_warning "The api endpoint color_collection(collection_id) is not implemented on this Looker instance"
      rescue LookerSDK::NotFound => nf
        say_warning "The color_collection(#{collection_id}) is not found"
      rescue LookerSDK::Error => e
        say_error "Error querying color_collection(#{collection_id})"
        say_error e.message
        raise
      end
      data
    end

    def find_vis_config_reference(obj, &block)
      if obj.respond_to?(:'has_key?') && obj.has_key?(:vis_config)
        yield (obj[:vis_config])
      elsif obj.is_a? Enumerable
        obj.each { |o| find_vis_config_reference(o,&block) }
      end
    end

    def find_color_palette_reference(obj, default_colors=nil, &block)
      begin
        dcc = default_color_collection()
        if dcc.nil?
          say_warning "You do not have access to query color palettes so these won't be processed."
          return
        end
        @default_colors=color_palette_lookup!(dcc)
        #say_warning("Default colors #{JSON.pretty_generate @default_colors}") if @options[:debug]
      end unless @default_colors

      if obj.respond_to?(:'has_key?') && obj.has_key?(:collection_id) && obj.has_key?(:palette_id)
        yield(obj,@default_colors)
      elsif obj.is_a? Enumerable
        obj.each { |o| find_color_palette_reference(o,@default_colors,&block) }
      end
    end

    def color_palette_lookup!(obj)
      return nil unless obj.respond_to?(:'has_key?')
      #say_warning("performing color_palette_lookup! on #{JSON.pretty_generate obj}") if @options[:debug]
      palettes = []
      palettes += obj[:categoricalPalettes] if obj[:categoricalPalettes]
      palettes += obj[:sequentialPalettes] if obj[:sequentialPalettes]
      palettes += obj[:divergingPalettes] if obj[:divergingPalettes]
      obj[:palettes]=palettes
      #say_warning("got palettes #{JSON.pretty_generate palettes}") if @options[:debug]
      obj
    end

    def rewrite_color_palette!(o,default_colors)
      cc = nil
      if o[:collection_id] == default_colors[:id]
        o[:collection_default] = true
        cc = default_colors
      else
        o[:collection_default] = false
        #say_ok("looking up color collection by id #{o[:collection_id]}") if @options[:debug]
        cc = color_palette_lookup!(color_collection(o[:collection_id]))
      end
      return unless cc
      #say_warning("got color collection #{JSON.pretty_generate cc}") if @options[:debug]
      o[:collection_label] = cc[:label]
      ps = cc[:palettes].select { |p| p[:id] == o[:palette_id] }
      if ps.length > 0
        p = ps.first
        o[:palette_label] = p[:label]
        o[:palette_type] = p[:type]
        o[:palette_colors] = p[:colors] if p[:colors]
        o[:palette_stops] = p[:stops] if p[:stops]
      end
    end

    def update_color_palette!(o,default_colors,force_default=false)
      return unless o.has_key?(:collection_label) && o.has_key?(:palette_type)

      cc = default_colors
      if !(force_default && o[:collection_default])
        # look up color collection by id
        #say_warning("attempting to match palette on id #{o[:collection_id]}") if @options[:debug]
        cc = color_palette_lookup!(color_collection(o[:collection_id]))
        if cc.nil?
          # find color collection by name
          #say_warning("no match on id, attempting to match palette on name #{o[:collection_label]}") if @options[:debug]
          ccs = all_color_collections()&.select { |cc| o[:collection_label] == cc[:label]}
          if ccs.nil? || ccs.length == 0
            # no color collection found. Use default.
            say_warning "Color collection #{o[:collection_label]} not found. Using default."
            cc = default_colors
          else
            cc = color_palette_lookup!(ccs.first)
          end
        end
      end
      o[:collection_id] = cc[:id]

      # look up palette by id
      ps = cc[:palettes].select {|p| p[:id] == o[:palette_id]}
      if ps.length == 0
        # find palette by type
        ps = cc[:palettes].select {|p| p[:type] == o[:palette_type]}
        if ps.length > 0
          o[:palette_id] = ps.first[:id]
        else
          # no palette found
          say_warning "Color palette #{o[:palette_type]} not found."
          o.delete(:palette_id)
        end
      end
    end

    ##
    # This method accepts the name of an sdk operation, then finds the parameter for that
    # operation in the data structures from the swagger.json file. The parameter is a
    # json object. Some of the attributes of the json object are read-only, and some
    # are read-write. A few are write-only. The list of read-write and write-only attribute
    # names are returned as an array. That array can be used to take the json document that
    # describes an object and strip out the read-only values, creating a document that can
    # be used to create or update an object.
    #
    # The pattern typically looks like this...
    #
    #   new_obj_hash = existing_obj_hash.select do |k,v|
    #     keys_to_keep('create_new_obj').include? k
    #   end

    def keys_to_keep(operation)
      o = @sdk.operations[operation] || @sdk.operations[operation.to_sym]
      begin
        say_error "Operation #{operation} not found"
        return []
      end unless o

      parameters = o[:info][:parameters].select { |p| p[:in] == "body" && p[:schema] }

      say_warning "Expecting exactly one body parameter with a schema for operation #{operation}" unless parameters.length == 1
      schema_ref = parameters[0][:schema][:$ref].split(/\//)
      return @sdk.swagger[schema_ref[1].to_sym][schema_ref[2].to_sym][:properties].reject { |k,v| v[:readOnly] }.keys
    end

    ##
    # The tty-table gem is normally used to output tabular data. This method accepts a Table
    # object as used by the tty-table gem, and generates CSV output. It returns a string
    # with crlf encoding

    def render_csv(t)
      io = StringIO.new
      io.puts (
        t.header.collect do |v|
          v ? "\"#{v.to_s.gsub(/"/, '""')}\"" : ""
        end.join(',')
      ) unless @options[:plain]
      t.each do |row|
        next if row === t.header
        io.puts (
          row.collect do |v|
            v ? "\"#{v.to_s.gsub(/"/, '""')}\"" : ""
          end.join(',')
        )
      end
      io.rewind
      io.gets(nil).encode(crlf_newline: true)
    end

    ##
    # This method accepts a string containing a list of fields. The fields can be nested
    # in a format like...
    #
    # 'a,b,c(d,e(f,g)),h'
    #
    # representing a structure like
    #
    # {
    #   a: "val",
    #   b: "val",
    #   c: {
    #     d: "val",
    #     e: {
    #       f: "val",
    #       g: "val"
    #     }
    #   },
    #   h: "val"
    # }
    #
    # That string will get parsed and yield an array like
    # [ a, b, c.d, c.e.f, c.e.g, h ]
    #

    def field_names(opt_fields)
      fields = []
      token_stack = []
      last_token = false
      tokens = opt_fields.split /(\(|,|\))/
      tokens << nil
      tokens.each do |t|
        if t.nil? then
          fields << (token_stack + [last_token]).join('.') if last_token
        elsif t.empty? then
          next
        elsif t == ',' then
          fields << (token_stack + [last_token]).join('.') if last_token
        elsif t == '(' then
          token_stack.push(last_token)
        elsif t == ')' then
          fields << (token_stack + [last_token]).join('.') if last_token
          token_stack.pop
          last_token = false
        else
          last_token = t
        end
      end
      fields
    end

    ##
    # This method will accept a field name in a format like 'c.e.g'
    # and convert it into 'c&.e&.g', which can be evaluated to get
    # the value of g, or nil if any intermediate value is nil.

    def field_expression(name)
      parts = name.split(/\./)
      parts.join('&.')
    end

    ##
    # This method will accept two arrays, a and b, and create a third array
    # like [ [a[0],b[0]], [a[1],b[1]], [a[2],b[2]], ...].
    # If either array is longer than the other, additional pairs 
    # will be generated with the shorter array padded out with nil values.
    #
    # Any additional args will be added to each inner array.

    def pairs(a, b, *args)
      pair_array = Array.new([a.count,b.count].max) do |i|
        pair = [a.fetch(i,nil),b.fetch(i,nil)]
        pair += args if args
        pair
      end

      return pair_array unless block_given?

      pair_array.collect { |e| yield(e) }
    end
  end
end
