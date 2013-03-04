# -*- encoding : utf-8 -*-
require 'bundler'
Bundler.setup(:default)
require 'ljapi/request'
require 'ljapi/login'
require 'ljapi/post'

module LJAPI
	class Cache
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
	end
end
