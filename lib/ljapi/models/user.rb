module LJAPI
	module Models
		class User < ActiveRecord::Base
			has_no_table
			column :login, :string
			column :password, :string

			def username
				self.login.to_s
			end

			def password
				self.password.to_s
			end
		end
	end
end