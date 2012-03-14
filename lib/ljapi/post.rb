require 'ljapi/request'
require 'cgi'

module LJAPI
  module Request
    class AddComment < Req
      def initialize(user, id, anum, text)
        super('addcomment', user)
        @id = id * 256 + anum
        @text = text
        @request.update({
          'body' => @text,
          'ditemid' => @id
        })
      end
      
      def run
        super
        @result['commentlink']
      end
    end
    
    class EditPost < Req
      def initialize(user, id, options)
        super('editevent', user)
        @id = id
        @request.update({ 'itemid' => @id })
        @request.update(options) if options
      end
      
      def run
        super
        @result
      end
    end
    
    class GetPosts < Req
      def initialize(username, password, options = nil)
        super('getevents', username, password)
        @request['lineendings'] = 'unix'
        @request['noprops'] = 'true'
        @request['notags'] = 'true'
        if options and options['since']
          @request['selecttype'] = 'syncitems'
          @request['lastsync'] = LJAPI::Utils::time_to_ljtime(options['since'])
        else
          @request['selecttype'] = 'lastn'
          @request['howmany'] = '50'
        end
      end
      
      def run
        super
        @result[:data]['events'].collect! { |post| post.each { |k,v| k.to_s; v.to_s.force_encoding('utf-8').encode }}
        return @result
      end
    end
  end
end