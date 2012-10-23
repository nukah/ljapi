# -*- encoding : utf-8 -*-
require 'ljapi/request'
require 'ljapi/utils'

module LJAPI
  module Request
    class Encode
      def self.to_proc
        lambda { |post|
          post.each { |k,v| 
            k.to_s
            v.to_s.force_encoding('utf-8').encode 
          }
        }
      end
    end
    
    class Censore
      def self.to_proc
        lambda { |post|
          post.update({ 'censored' => LJAPI::Utils.check_censore(post) })
        }
      end
    end
    
    class DeEmbed
      def self.to_proc
        lambda { |post| 
          return LJAPI::Utils.check_video(post)
        }
      end
    end
    
    class Properties
      def self.to_proc
        lambda { |post|
          props = post['props']
          created = post['eventtime']
          post.delete('props')
          post.update({ 'allow_comments' => LJAPI::Utils.allow_comments(props) })
          post.update({ 'last_edit_date' => LJAPI::Utils.last_edit(props,created) })
          post.update({ 'tags' => LJAPI::Utils.get_tags(props) })
        }
      end
    end


    
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
      def initialize(username, password, journal = nil, id, subject, text)
        super('addcomment', username, password)
        @request.update({ 'journal' => journal }) if journal
        @request.update({
          'body' => text.slice(0,4299),
          'ditemid' => id,
          'subject' => subject.slice(0,100)
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
        @request.update({ 'itemid' => id })
        @request.merge!(options) if options and options.kind_of?(Hash)
      end
      
      def run
        super
        @result
      end
    end
    
    class GetPost < Req
      def initialize(username, password, journal_id, post_id, options = nil)
        @username = journal_id
        super('getevents', username, password)
        @request.update({
          'selecttype'  => 'one',
          'notags'      => 'false',
          'parseljtags' => 'true',
          'itemid'      => (post_id != -1 and post_id.to_i or -1),
          'usejournal'  => journal_id.to_s
        })
        @request.merge!(options) if options and options.kind_of?(Hash)
      end
      
      def run
        super
        if @result[:success]
            @result[:data]['events'].each { |post| LJAPI::Utils.convert_urls(post, @username) }
            @result[:data]['events'].map!(&Encode).map!(&Properties).map!(&Censore).reject!(&DeEmbed)
        end
        return @result
      end
    end

    class CountPosts < Req
      def initialize(username, password)
        super('getevents', username, password)
        @request.update({
          'selecttype'  => 'one',
          'notags'      => 'true',
          'parseljtags' => 'false',
          'itemid'      => -1,
          'usejournal'  => username
        })
      end

      def run
        super
        if @result[:success]
          return @result[:data]["events"][0]["itemid"].to_i
        else
          throw Exception.new('failure')
        end
      end
    end
    
    class GetPosts < Req
      def initialize(username, password, options = {})
        @username = username
        super('getevents', username, password)
        @request.update({
          'lineendings'   => 'unix',
          'notags'        => 'false',
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
          @result[:data]['events'].each { |post| LJAPI::Utils.convert_urls(post, @username) }
          @result[:data]['events'].map!(&Encode).map!(&Properties).map!(&Censore).reject!(&DeEmbed)
        end
        return @result
      end
    end
  end
end