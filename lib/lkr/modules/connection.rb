# frozen_string_literal: true

module Lkr
  module Connection

    def query_all_connections(fields=nil)
      data = nil
      begin
        data = @sdk.all_connections(fields ? {:fields=>fields} : nil )
      rescue LookerSDK::Error => e
          say_error "Error querying all_connections({:fields=>\"#{fields}\"})"
          say_error e.message
          raise
      end
      data
    end

    def query_all_dialects(fields=nil)
      data = nil
      begin
        data = @sdk.all_dialect_infos(fields ? {:fields=>fields} : nil )
      rescue LookerSDK::Error => e
          say_error "Error querying all_dialect_infos({:fields=>\"#{fields}\"})"
          say_error e.message
          raise
      end
      data
    end

  end
end