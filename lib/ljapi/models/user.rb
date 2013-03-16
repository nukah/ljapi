module LJAPI
	module Models
		class User < ActiveRecord::Base
			has_no_table
			attr_accessor :username, :password
			column :username, :text
			column :password, :text
		end
	end
end