# -*- encoding : utf-8 -*-
require "xmlrpc/client"
require "digest/md5"

DEBUG = false

module LJAPI
  module Request
    
    MAX_ATTEMPTS = 5
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
    
    class Req
      def initialize(operation, username = nil, password = nil)
        @operation = operation
        @request = {
          "clientversion" => "Ruby",
          "ver" => "1",
          "operation" => self.class.to_s.split("::").last.downcase,
        }
        @result = {}
        if username && password
          challenge = Challenge.new.run
          response = Digest::MD5.hexdigest(challenge + password.to_s)
          @request.update({
            "username" => username.to_s,
            "auth_method" => "challenge",
            "auth_challenge" => challenge,
            "auth_response" => response,
            })
        end
      end

      def run
        return LJAPI::Cache.get(@request) if LJAPI::Cache.check_request(@request)

        connection = XMLRPC::Client.new("www.livejournal.com", "/interface/xmlrpc")
        connection.timeout = 60
        event = "LJ.XMLRPC.#{@operation}"
        attempts = 0

        begin
          attempts += 1
          result, data = connection.call2(event, @request)
          data.delete("skip") if data.class == Hash && data.key?("skip")
        #rescue EOFError, RuntimeError, Errno::ECONNREFUSED => e
        rescue Exception => e
          sleep 5 and retry if(attempts < MAX_ATTEMPTS)
          err = e.message
        ensure
          if result == false
           error = ERROR_CODES[data.to_s].nil? ? err : ERROR_CODES[data.to_s]
          end
          @result.update({
            :success  => result,
            :data     => (result and data or error),
          })
          @result.update({:data_full => data.inspect}) if (!result and DEBUG)
        end

        LJAPI::Cache.save(@request, @result)

        return @result
      end
    end
    
    class Challenge < Req
      def initialize
        super("getchallenge")
      end
      
      def run
        super
        return @result[:data]["challenge"]
      end
    end
  end
end