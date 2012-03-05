require 'xmlrpc/client'
require 'digest/md5'
require 'ljapi/user'
require 'date'

module LJAPI
  module Request
    MAX_ATTEMPTS = 5
    
    def self.time_to_ljtime(time)
          time.strftime '%Y-%m-%d %H:%M:%S'
    end
        
    def self.ljtime_to_time(str)
          dt = DateTime.strptime(str, '%Y-%m-%d %H:%M')
          Time.gm(dt.year, dt.mon, dt.day, dt.hour, dt.min, 0, 0)
    end
    
    class LJException < Exception 
      attr_accessor :code
      def initialize(error)
        @code = error
      end
    end
    
    class Req
      def initialize(operation, username = nil, password = nil)
        @operation = operation
        @request = {
          'clientversion' => 'Ruby',
          'ver' => 1
        }
        if username and password
          challenge = Challenge.new
          response = Digest::MD5.hexdigest(challenge + Digest::MD5.hexdigest(password))
          @request.update({
            'username' => username,
            'auth_method' => 'challenge',
            'auth_challenge' => challenge,
            'auth_response' => response,
            'usejournal' => username,
            })
        end
        self.run
      end

      def run
        connection = XMLRPC::Client.new('www.livejournal.com', '/interface/xmlrpc')
        connection.timeout = 60
        event = 'LJ.XMLRPC'.concat('.').concat(@operation)
        attempts = 0
        begin
          attempts += 1
          ok, res = connection.call2(event, @request)
        rescue EOFError, RuntimeError
          retry if(attempts < MAX_ATTEMPTS)
        rescue Timeout::Error, Errno::ETIMEDOUT
          return { :success => false, :data => { :error => 'timeout' } }
        end
        return { :success => false, :data => { :error => 'access_error' } } if !ok
        return { :success => true, :data => res }
      end
    end

    class Challenge < Req
      def initialize
        super('getchallenge')
      end

      def run
        super[:data]
      end
    end
  end
end