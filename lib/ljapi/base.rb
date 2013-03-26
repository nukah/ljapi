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
        EM.run do
          Fiber.new { 
            if post.has_video?
              connection = Faraday.new post.url { |c|
                c.adapter :em_http
              }
              response = connection.get
              response.on_complete {
                page = Nokogiri::HTML(response.body)
                post.text = Sanitize.clean(post.text, 
                  :elements => %w[ a b blockquote br cite code img dd div dl dt em i li ol p pre strong u ul ],
                  :attributes => { 'a' => ['href'], 'img' => ['src'], 'div' => ['style'] },
                  :protocols => { 'a' => {'href' => ['ftp', 'http', 'https', 'mailto', :relative] } },
                  :remove_contents => %w[ form script ])
                page.css('.lj_embedcontent').each { |video| post.text.sub!(/<a([^>]+)>View movie.<\/a>/, video.to_html) }
              }
            end
            Fiber.yield
            EM.stop
          }.resume
        end
      end
    end

    class ResponseObject
      attr_reader :response
      def initialize operation, status = nil, result = nil, error = nil
        form_response(operation, status, result, error)
      end

      def form_response(operation, status, result, error)
        result.delete("skip") if status && result.include?("skip")
        if operation == "getevents"
          posts = []
          result['events'].each { |post|
            posts << LJAPI::Models::Post.new(
              id: post['itemid'],
              subject: post['subject'],
              text: post['event'],
              published: post['eventtime'],
              url: post['url'],
              replies: post['reply_count'],
              props: post['props']
            )
          } if result['events'].any?

          posts.each { |post| Wrapper.new(post) } if posts.any?
          @response = { status: status, result: posts, error: error }
        else
          @response = { status: status, result: result, error: error }
        end
      end

      def status
        @response[:status]
      end

      def result
        @response[:result]
      end

      def error
        @response[:error]
      end

      def to_json
        @response.to_json
      end

      def method_missing method
        @response[:result][method.to_s]
      end
    end
  end
end