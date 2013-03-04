require 'ljapi'
require File.dirname(__FILE__) + '/spec_helper'
require 'ruby-prof'

describe 'LiveJournal API Perfomance' do
	describe LJAPI::Request::GetPosts do
		it 'perfomance test' do
			result = RubyProf.profile { LJAPI::Request::GetPosts.new('fir3', 'f403b0755e1edb2b6e3cd7bc443bf4dc').run }
			printer = RubyProf::FlatPrinterWithLineNumbers.new(result)
			printer.print(STDOUT)
		end
	end
end