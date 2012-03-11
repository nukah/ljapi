require 'xmlrpc/client'
require 'digest/md5'
require 'ljapi/user'
require 'date'

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
          :data     => (result and data or data.code)
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