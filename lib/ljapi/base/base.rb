module LJAPI
	module Base
		class RequestObject
			def initialize(username, password, type)
				@username = username
				@password = password
				@operation = type

				@client = "Lanshera API"
				@client_version = "1"

				@line_endings = 'unix'
				#common
				'lineendings'   => 'unix',
				'notags'        => 'false',
				'parseljtags'   => 'true',
				'selecttype'  => 'syncitems',
				'lastsync'    => LJAPI::Utils.time_to_ljtime(options['since'])
				'howmany'     => '50'
				'itemid'      => -1,
				'usejournal'  => username
				# add_comment
				'body' => text.slice(0,4299),
				'ditemid' => id,
				'subject' => subject.slice(0,100)
			end

			def get_post

			end

			def count_posts

			end 

			def import_posts

			end

			def add_comment

			end

			def update_journal

			end
		end

		class ResponseObject
			def initialize

			end
		end
	end
end