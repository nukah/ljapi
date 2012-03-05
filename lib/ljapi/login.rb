require 'ljapi/request'

module LJAPI
  module Request
    class Login < Req
      def initialize(user)
        super('login', user)
      end


      def run
        super
        u = @user
        u.fullname = @result['fullname']
        u
      end
    end
  end
end