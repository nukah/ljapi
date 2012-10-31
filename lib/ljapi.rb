# -*- encoding : utf-8 -*-
require 'ljapi/request'
require 'ljapi/login'
require 'ljapi/post'
require 'connection_pool'
require 'dalli'

module LJAPI
	module Cache
		CACHE_OPS = %w[getposts importposts]
		def self.store=(options)
			if options.is_a?(Hash)
				url = options[:url] || "localhost:11211"
				expires = options[:expires] || 5*60
				socket_timeout = options[:socket_timeout] || 0.2
				username = options[:username] || nil
				password = options[:password] || nil
			end

			@cache = ConnectionPool.new(:timeout => 1, :size => 5) do
				Dalli::Client.new(url, :expires_in => expires, 
									   :socket_timeout => socket_timeout,
									   :username => username, 
									   :password => password)
			end
		end

		def self.get(request)
			cache_key = "#{request['operation']}:#{request['username']}"
			@cache.with_connection do |cache|
				@result = cache.get(cache_key)
			end
			return @result
		end

		def self.check_request(request)
			if CACHE_OPS.include?(request['operation'])
				cache_key = "#{request['operation']}:#{request['username']}"
				@cache.with_connection do |cache|
					@result = cache.get(cache_key)
				end
				return @result.nil? ? false : true
			else
				return false
			end
		end

		def self.save(request, result)
			if CACHE_OPS.include?(request['operation'])
				cache_key = "#{request['operation']}:#{request['username']}"
				@cache.with_connection do |cache|
					cache.set(cache_key, result)
				end
			end
		end

		def self.configure
			yield self
		end
	end
end
