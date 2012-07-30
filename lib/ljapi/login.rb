# -*- encoding : utf-8 -*-
require 'ljapi/request'

module LJAPI
  module Request
    class AccessCheck < Req
      def initialize(username, password)
        super('sessiongenerate', username, password)
      end
      
      def run
        super
        @result.delete :data
        return @result
      end
    end
  end
end
