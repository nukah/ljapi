# -*- encoding : utf-8 -*-
require 'ljapi/utils'

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
      def initialize(username, password, journal = nil, id, subject, text)
        @user = LJAPI::Models::User.new(username, password)
        super('addcomment', @user)
        @request.update({ 'journal' => journal }) if journal
        @request.update({
            body: text.slice(0,4299),
            ditemid: id,
            subject: subject.slice(0,100)
        })
      end
      
      def run
        super
      end
    end
    
    class GetPost < Req
      def initialize(username, password, journal = username, post_id = -1)
        @user = LJAPI::Models::User.new(username: username, password: password)
        super('getevents', @user)
        @request.update({
          selecttype: 'one',
          usejournal: journal,
          itemid: post_id
        })
      end
      
      def run
        super
      end
    end

    class CountPosts < GetPost
      def initialize(username, password)
        super
      end

      def run
        super
        @response.post_id
      end
    end
    
    class GetPosts < Req
      def initialize(username, password, options = {})
        @user = LJAPI::Models::User.new(login: username, password: password)
        super('getevents', @user)
        if options.has_key?('since')
          @request.update({
            selecttype: 'syncitems',
            lastsync: LJAPI::Utils.time_to_ljtime(options['since'])
          })
        elsif options.has_key?('itemids')
          @request.update({
            selecttype: 'multiple',
            partial: true
           })
        else
          @request.update({
            selecttype: 'lastn',
            howmany: '50'
          })
        end
      end
      
      def run
        super
      end
    end

    class ImportPosts < Req
      def initialize(username, password)
        @user = LJAPI::Models::User.new(login: username, password: password)
        super('getevents', username, password)
        @journal_count = LJAPI::Request::CountPosts.new(@user.username, @user.password).run
        @journal_items = (1..@journal_count).to_a
        @journal_posts = []
      end

      def run
        @threads = []
        (@journal_count.to_f/100.to_f).ceil.times { |thread|
          @threads << Thread.new {
            begin 
              partial_posts = LJAPI::Request::GetPosts.new(@user.username, @user.password, { 'itemids' => @journal_items.shift(100).join(',') }).run
              @journal_posts.push(partial_posts)
            end
          }
        }
        @threads.each { |thr| thr.join }
        @response.combine @journal_posts
        @response
      end
    end
  end
end