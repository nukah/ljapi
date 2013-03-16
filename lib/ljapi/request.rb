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
    
    class Connection
      attr_reader :response
      def initialize request_object = nil
        request = (request_object || LJAPI::Base::RequestObject.new)

        operation = name(request.operation)
        connection = XMLRPC::Client.new("www.livejournal.com", "/interface/xmlrpc")
        connection.timeout = 60

        @response = Fiber.new {
          attempts = 0
          begin
            attempts += 1
            call_result, call_response = connection.call2(operation, request.to_h)
          # rescue Exception => e
          #   sleep 5 and retry if(attempts < 5)
          #   puts e.message
          
            error = ERROR_CODES[response.to_s] if !call_result
            response = LJAPI::Base::ResponseObject.new(operation, call_result, call_response, error)
            Fiber.yield response
          end
        }.resume
      end

      private

      def name method
        "LJ.XMLRPC.#{method.to_s}"
      end
    end

    class Req
      def initialize(operation, user, options = nil)
        chal = Connection.new.response
        @request = LJAPI::Base::RequestObject.new(user, operation).challenge(chal)
      end

      def run
        Connection.new(@request).response
      end
    end
  end
end