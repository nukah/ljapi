module LJAPI
	module Models
		class Journal < ActiveRecord::Base
			has_no_table
			has_many :posts

			column :jid, :string
			column :imported, :boolean
			column :updated, :datetime
		end
	end
end