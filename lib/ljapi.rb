# -*- encoding : utf-8 -*-
require 'ljapi/request'
require 'ljapi/login'
require 'ljapi/post'
require 'dalli'

module LJAPI
	class Cache
		CACHE_OPS = %w[getposts importposts]
		def self.store(options)
			if options.is_a?(Hash)
				url = options[:url]
				expires = options[:expires] || 5*60
				socket_timeout = options[:socket_timeout] || 0.2
				username = options[:username]
				password = options[:password]
			end

			@@cache = Dalli::Client.new(url, :expires_in => expires, 
									   :socket_timeout => socket_timeout,
									   :username => username, 
									   :password => password)
		end

		def self.cache
			@@cache
		end

		def self.perform(action, operation, username, value = nil)
			begin
				if defined?(@@cache) && !@@cache.nil?
					return @@cache.send(action, "#{operation}:#{username}", value) if CACHE_OPS.include?(operation)
				end
			rescue Dalli::RingError
				return
			end
		end

		def self.get(request)
			perform(:get, "#{request['operation']}", "#{request['username']}")
		end

		def self.check_request(request)
			perform(:get, "#{request['operation']}", "#{request['username']}").nil? ? false : true
		end

		def self.save(request, result)
			perform(:set, "#{request['operation']}", "#{request['username']}", result)
		end

		def self.configure
			yield self
		end
	end
end
