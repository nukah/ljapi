require 'ljapi/request'

module LJAPI
  class User
    attr_accessor :username, :password
    def initialize(user, password)
      @username = user
      @password = password
    end
    def journal
      @username
    end
    def to_s
      "#{@username}"
    end
  end
end