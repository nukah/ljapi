# -*- encoding : utf-8 -*-
require "xmlrpc/client"
require 'ljapi/base'
require 'eventmachine'
require 'em-xmlrpc-client'

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
      def self.connect operation = nil, request
        xml_operation = convert_name_to_xmlrpc_method(operation)
        EM.run do 
          Fiber.new do
            connection = XMLRPC::Client.new("www.livejournal.com", "/interface/xmlrpc")
            connection.timeout = "60"
            call_status, call_response = connection.call2(xml_operation, request)
            error = call_status ? false : ERROR_CODES[call_response.to_s]
            @response = LJAPI::Base::ResponseObject.new(operation, call_status, call_response, error)
            EM.stop
          end.resume
        end
        @response
      end

      private

      def self.convert_name_to_xmlrpc_method method
        "LJ.XMLRPC.#{method.to_s}"
      end
    end

    class Req
      def initialize(operation, *options)
        options = options.first if options.any?
        @operation = operation
        @request = { 
          client: "Lanshera API",
          client_version: 1,
          line_endings: 'unix',
          notags: 'false',
          parseljtags: 'true',
        }
        @request.merge!(options) if options.any?
        unless operation == 'getchallenge'
          raise ArgumentError unless (options.include?(:username) || options.include?(:password))
          chal = Challenge.new.run
          username = options[:username] if options.has_key?(:username)
          password = options[:password] if options.has_key?(:password)
          auth = Digest::MD5.hexdigest(chal.challenge + password)
          @request.update({
            auth_method: 'challenge',
            auth_challenge: chal.challenge,
            auth_response: auth
          })
        end
      end

      def run
        @response = Connection.connect(@operation, @request)
        @response
      end
    end

    class Challenge < Req
      def initialize
        super('getchallenge')
      end

      def run
        super
      end
    end
  end
end