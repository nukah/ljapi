class User < ActiveRecord::Base
	has_no_table
	column :login, :string
	column :password, :string
	
end