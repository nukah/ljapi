require 'ljapi'
require File.dirname(__FILE__) + '/spec_helper'

describe 'LiveJournal API' do
	before :each do
		@credentials = { login: 'lshtest', password: 'ae469fef41e89a0d25a518bcaf1b48fb' }
	end

	describe LJAPI::Request::GetPost do

		it "should get single specific post" do
		  results = LJAPI::Request::GetPost.new(@credentials[:login], @credentials[:password], @credentials[:login], 5).run
		  results[:data]['events'].first.should be_a_kind_of(Hash)
		  results[:data]['events'].first['url'] =~ /\/\/#{@credentials[:login]}.livejournal.com\/\d+.html/
		end

		it "should get last post" do
		  results = LJAPI::Request::GetPost.new(@credentials[:login], @credentials[:password], @credentials[:login], -1).run
		  results[:data]['events'].first.should be_a_kind_of(Hash)
		  results[:data]['events'].first['url'] =~ /\/\/#{@credentials[:login]}.livejournal.com\/\d+.html/
		end

	end
	
	describe LJAPI::Request::GetPosts do

		before :each, :authorized => true do
			request = LJAPI::Request::GetPosts.new(@credentials[:login], @credentials[:password]).run
			@results = request[:data]['events']
		end

	  	it "should return array of posts", :authorized => true do
		    @results.should be_a_kind_of(Array)
		    @results.size.should be > 10
	  	end

		it "should have posts encoded and has specific fields", :authorized => true do
			@results.first.keys.should include('subject', 'event', 'ditemid', 'allow_comments', 'censored', 'last_edit_date')
		end

		it "should retrieve posts since specific date" do
			result = LJAPI::Request::GetPosts.new(@credentials[:login], @credentials[:password], { 'since' => '07.03.2012' }).run
			result[:data]['events'].size.should be > 3
			result[:data]['events'].first['itemid'].should == 4
			Date.parse(result[:data]['events'].first['eventtime']).should be >= Date.parse('06.03.2012')
		end

	end

	describe LJAPI::Request::AccessCheck do

		it "should return success" do
			request = LJAPI::Request::AccessCheck.new(@credentials[:login], @credentials[:password]).run
			request.should include(:success)
			request[:success].should == true
		end

		it "should fail on wrong creds" do
		  	request = LJAPI::Request::AccessCheck.new('fail', 'login').run
		  	request[:success].should == false
		end

	end
end