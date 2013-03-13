# -*- encoding : utf-8 -*-
require "xmlrpc/client"
require 'ljapi/base'

module LJAPI
  module Request
    ERROR_CODES = {
      "Invalid username" => 100,
      "Invalid password" => 101,
      "Poll error" => 103,
      "Challenge expired" => 105,
      "Incorrect time value" => 153,
      "Non-validated email address" => 155,

      "Missing required argument(s)" => 200,
      "Invalid destination journal username" => 206,
      "Invalid text encoding" => 208,
      "Message body is too long" => 212,
      "Message body is empty" => 213,
      "Message looks like spam" => 214,

      "Don't have access to requested journal" => 300,
      "Unknown Error" => 302,
      "Action forbidden; account is suspended" => 305,
      "Selected journal no longer exists" => 307,
      "Account is locked and cannot be used" => 308,
      "Access temporarily disabled" => 311,
      "Sorry, there was a problem with entry content" => 320,

      "Your IP address has been temporarily banned for exceeding the login failure rate" => 402,
      "Post frequency limit" => 405,
      "Client is making repeated requests. Perhaps it's broken?" => 406,
      "Maximum queued posts for this <community+poster> combination reached" => 408,
      "Post is too large" => 409,
      "Action frequency limit" => 411,

      "Internal server error" => 500,
      "Database error" => 501,
      "Database is temporarily unavailable" => 502,
      "Error obtaining necessary database lock" => 503,
      "Protocol mode no longer supported" => 504,
      "Account data format on server is old and needs to be upgraded" => 505,
      "Journal sync is temporarily unavailable" => 506
    }
    class LJException < Exception
    end
    
    class Connection
      def initialize request = nil, response = nil
        @request = request
        partial = @request.partial
        @response = ResponseObject.new(partial)
        @connection = XMLRPC::Client.new("www.livejournal.com", "/interface/xmlrpc")
        @connection.timeout = 60
        @operation = name(@request.operation || 'getchallenge')
        Fiber.new {
          attempts = 0
          begin
            attempts += 1
            bool, response = @connection.call2_async(@operation, @request)
            response.delete("skip") if response.class == Hash && response.key?("skip")
          rescue Exception => e
            sleep 5 and retry if(attempts < 5)
          ensure
            error = ERROR_CODES[response.to_s] if !bool
            @response.form(success: bool, response: response, error: error)
            Fiber.yield @response
        }.resume
      end

      private

      def name method
        "LJ.XMLRPC.#{method.to_s}"
      end
    end

    class Req
      def initialize(operation, user, options)
        @user = user
        #@type = self.class.to_s.split("::").last.downcase
        @operation = operation

        @challenge = Connection.new()
        @request = RequestObject.new(@user, @operation).challenge(@challenge)
      end

      def run
        @response = Connection.new(@request)
      end
    end
  end
end