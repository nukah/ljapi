class Post < ActiveRecord::Base
	has_no_table
	belongs_to :journal

	column :id, :integer
	column :subject, :string
	column :text, :string
	column :published, :datetime
	column :url, :string
	column :anum, :integer
	column :replies, :integer
	column :visibility, :string
	column :commentable, :boolean
end