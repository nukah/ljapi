require 'ljapi/request'
require 'cgi'

module LJAPI
  module Request
    class AddComment < Req
      def initialize(username, password, journal, id, subject, text)
        super('addcomment', username, password)
        @request.update({
          'journal' => journal,
          'body' => text,
          'ditemid' => id,
          'subject' => subject
        })
      end
      
      def run
        super
        return @result
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
    
    class GetPost < Req
      def initialize(username, password, journal_id, post_id, options = nil)
        super('getevents', username, password)
        @request['selecttype'] = 'one'
        @request['notags'] = 'true'
        @request['itemid'] = (post_id/256).to_i
        @request['usejournal'] = journal_id.to_s
      end
      
      def run
        super
        if @result[:success]
            @result[:data]['events'].collect! { |post| post.each { |k,v| k.to_s; v.to_s.force_encoding('utf-8').encode }}
        end
      end
    end
    
    class GetPosts < Req
      def initialize(username, password, options = nil)
        super('getevents', username, password)
        @request['lineendings'] = 'unix'
        @request['noprops'] = 'true'
        @request['notags'] = 'true'
        @request['parseljtags'] = 'true'
        if options and options.kind_of?(Hash) and options['since']
          @request['selecttype'] = 'syncitems'
          @request['lastsync'] = LJAPI::Utils::time_to_ljtime(options['since'])
          @request.merge!(options)
        else
          @request['selecttype'] = 'lastn'
          @request['howmany'] = '50'
          @request.merge!(options) if options
        end
      end
      
      def run
        super
        if @result[:success]
          @result[:data]['events'].collect! { |post| post.each { |k,v| k.to_s; v.to_s.force_encoding('utf-8').encode }}
        end
        return @result
      end
    end
  end
end
