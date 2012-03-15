require 'xmlrpc/client'
require 'digest/md5'

# Quick fix for JSON.generate raising TypeError in Array with Fixnums.
@@error_codes = {
  "Invalid username" => 100,
  "Invalid password" => 101,
  "Poll error" => 103,
  "Challenge expired" => 105,
  "Incorrect time value" => 153,
  "Non-validated email address" => 155,
  #"Protocol authentication denied due to user’s failure to accept TOS." => 156,
  
  "Missing required argument(s)" => 200,
  "Invalid destination journal username" => 206,
  "Invalid text encoding" => 208,
  "Message body is too long" => 212,
  "Message body is empty" => 213,
  "Message looks like spam" => 214,
  
  "Don't have access to requested journal" => 300,
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

class Fixnum
  def to_json(options = nil)
    to_s
  end
end

module LJAPI
  module Request
    MAX_ATTEMPTS = 5
    
    class LJException < Exception 
    end
    
    class Req
      def initialize(operation, username = nil, password = nil)
        @operation = operation
        @request = {
          'clientversion' => 'Ruby',
          'ver' => '1',
          'operation' => @operation
        }
        @result = {}
        if username and password
          challenge = Challenge.new.run
          response = Digest::MD5.hexdigest(challenge + Digest::MD5.hexdigest(password))
          @request.update({
            'username' => username,
            'auth_method' => 'challenge',
            'auth_challenge' => challenge,
            'auth_response' => response,
            'usejournal' => username,
            })
        end
      end

      def run
        connection = XMLRPC::Client.new('www.livejournal.com', '/interface/xmlrpc')
        connection.timeout = 60
        event = 'LJ.XMLRPC'.concat('.').concat(@operation)
        attempts = 0
        begin
          attempts += 1
          result, data = connection.call2(event, @request)
        rescue EOFError, RuntimeError
          retry if(attempts < MAX_ATTEMPTS)
        rescue Errno::ECONNREFUSED => e
          raise LJException.new(e)
        end
        @result.update({
          :success  => result,
          :data     => (result and data or @@error_codes[data.faultString])
        })
        return @result
      end
    end

    class Challenge < Req
      def initialize
        super('getchallenge')
      end
      
      def run
        super
        return @result[:data]['challenge']
      end
    end
  end
end