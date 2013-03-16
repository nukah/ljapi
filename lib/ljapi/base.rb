require 'digest/md5'
require 'nokogiri'
require 'faraday'
require 'em-http-request'
require 'sanitize'
require 'xmlrpc/utils'

module LJAPI
  module Base
    class Wrapper
      def initialize(post)
        Fiber.new { 
          if post.has_video?
            connection = Faraday.new url { |c|
              c.adapter :em_http
            }
            response = connection.get
            response.on_complete {
              page = response.body
              page = Nokogiri::HTML(response)
              post.text = Sanitize.clean(post.text, 
                :elements => %w[ a b blockquote br cite code img dd div dl dt em i li ol p pre strong u ul ],
                :attributes => { 'a' => ['href'], 'img' => ['src'], 'div' => ['style'] },
                :protocols => { 'a' => {'href' => ['ftp', 'http', 'https', 'mailto', :relative] } },
                :remove_contents => %w[ form script ])
              page.css('.lj_embedcontent').each { |video| post.text.sub!(/<a([^>]+)>View movie.<\/a>/, video.to_html) }
            }
          end
          Fiber.yield
        }.resume
      end
    end

    class RequestObject
      def initialize(user = nil, type = nil)
        @user = user
        @request = { 
          client: "Lanshera API",
          client_version: 1,
          line_endings: 'unix',
          notags: 'false',
          parseljtags: 'true',
          operation: type || 'getchallenge'
        }
        self
      end

      def challenge response
        auth = Digest::MD5.hexdigest(response.challenge + @user.password)
        @request.update({
          username: @user.username,
          auth_method: 'challenge',
          auth_challenge: response.challenge,
          auth_response: auth
        })
        self
      end

      def to_h
        @request
      end

      def to_s
        @request.to_s
      end

      def update *options
        @request.update(options.first)  
      end

      def method_missing method
        @request[method.to_sym]
      end
    end

    class ResponseObject
      attr_reader :result
      def initialize operation, success = nil, response = nil, error = nil
        @operation = operation
        @success = success
        @response = response
        @error = error
        form_response
      end

      def form_response
        @response.delete("skip") if @response.class == Hash && @response.key?("skip")

        if @operation == "getevents"
          @posts = []
          if @response.events.any?
            puts 1
            @response.events.each do |post|
              puts post
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
          @result = { success: @success, result: @posts, error: @error }
        else
          @result = { success: @success, result: @response, error: @error }
        end
      end

      def method_missing method
        @response[method.to_s]
      end
    end
  end
end