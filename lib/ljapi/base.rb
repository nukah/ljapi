require 'digest/md5'
require 'nokogiri'
require 'httparty'
require 'sanitize'

module LJAPI
  module Base
    class Wrapper
      def initialize(post)
        Fiber.new { 
          if post.has_video?
            response = HTTParty.get(url).body
            page = Nokogiri::HTML(response)
            post.text = Sanitize.clean(post.text, 
              :elements => %w[ a b blockquote br cite code img dd div dl dt em i li ol p pre strong u ul ],
              :attributes => { 'a' => ['href'], 'img' => ['src'], 'div' => ['style'] },
              :protocols => { 'a' => {'href' => ['ftp', 'http', 'https', 'mailto', :relative] } },
              :remove_contents => %w[ form script ])
            page.css('.lj_embedcontent').each { |video| post.text.sub!(/<a([^>]+)>View movie.<\/a>/, video.to_html) }
          end
          Fiber.yield
        }.resume
      end
    end

    class RequestObject
      def initialize(user, type = nil)
        @user = user
        @request = { 
          client: "Lanshera API",
          client_version: 1,
          line_endings: 'unix',
          notags: 'false',
          parseljtags: 'true',
          operation: type
        }
      end

      def challenge response
        @response = response
        auth = Digest::MD5.hexdigest(@response.challenge + @user.password)
        @request.update({
          username: @user.username,
          auth_method: 'challenge',
          auth_challenge: response.challenge,
          auth_response: auth
        })
        self
      end

      def update *options
        @request.update(options)  
      end
    end

    class ResponseObject
      def initialize partial = nil
        @success = false
        @response = {}
        @error = nil
        @partial = partial
      end

      def form success, response, error = nil
        @success = success
        @response = response
        @error = error
        @posts = []
        if @response.has_key?('events') && @response.events.class == Hash && @response.events.any?
          @response.events.each do |post|
            @posts << LJAPI::Models::Post.new(
              id: post['itemid'],
              subject: post['subject'],
              text: post['event'],
              published: post['eventtime'],
              url: post['url'],
              replies: post['reply_count'],
              props: post['props']
            )
          end
        end

        @posts.each { |post| Wrapper.new(post) } if @posts.any?
        ## IF PARTIAL - DO NOT PROVIDE RESULTING RESPONSE OBJECT. INSTEAD PREPARE OBJECT FOR COMBINE
      end

      def combine posts

      end

      def method_missing method, *opts
        @response[method.to_s]
      end
    end
  end
end