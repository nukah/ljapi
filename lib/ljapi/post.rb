# -*- encoding : utf-8 -*-
require 'ljapi/request'
require 'ljapi/utils'
require 'cgi'

module LJAPI
  module Request

    class AddPost < Req
      def initialize(username, password, subject, text, options = nil)
        super('postevent', username, password)
        @request.update({
          'event'     => text,
          'subject'   => subject,
          'year'      => DateTime.now.year,
          'mon'       => DateTime.now.mon,
          'day'       => DateTime.now.day,
          'hour'      => DateTime.now.hour,
          'min'       => DateTime.now.min
        })
        @request.merge!(options) if options
      end

      def run
        super
        return @result
      end
    end

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
      def initialize(user, id, options = nil)
        super('editevent', user)
        @id = id
        @request.update({ 'itemid' => @id })
        @request.merge!(options) if options and optins.kind_of?(Hash)
      end
      
      def run
        super
        @result
      end
    end
    
    class GetPost < Req
      def initialize(username, password, journal_id, post_id, options = nil)
        super('getevents', username, password)
        @request.update({
          'selecttype'  => 'one',
          'notags'      => 'true',
          'noprops'     => 'true',
          'itemid'      => (post_id != -1 and post_id.to_i or -1),
          'usejournal'  => journal_id.to_s
        })
        @request.merge!(options) if options and optins.kind_of?(Hash)
      end
      
      def run
        super
        if @result[:success]
            @result[:data]['events'].collect! { |post| post.each { |k,v| k.to_s; v.to_s.force_encoding('utf-8').encode }}
            @result[:data]['events'].each { |post| post.store('censored', LJAPI::Utils.check_censore(post['event'])) }
        end
        return @result
      end
    end
    
    class GetPosts < Req
      def initialize(username, password, options = {})
        super('getevents', username, password)
        @request.update({
          'lineendings'   => 'unix',
          'noprops'       => 'true',
          'notags'        => 'true',
          'parseljtags'   => 'true'
        })
        if options.has_key?('since')
          @request.update({
            'selecttype'  => 'syncitems',
            'lastsync'    => LJAPI::Utils.time_to_ljtime(options['since'])
          })
          options.delete('since')
        elsif options.has_key?('itemids')
          @request.update({
            'selecttype'  => 'multiple'
           })
        else
          @request.update({
            'selecttype'  => 'lastn',
            'howmany'     => '50'
          })
        end
        @request.merge!(options)
      end
      
      def run
        super
        if @result[:success]
          @result[:data]['events'].collect! { |post| post.each { |k,v| k.to_s;v.to_s.force_encoding('utf-8').encode } }
          @result[:data]['events'].each { |post| post.store('censored', LJAPI::Utils.check_censore(post['event'])) }
        end
        return @result
      end
    end

  end
end