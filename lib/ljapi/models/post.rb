# -*- encoding : utf-8 -*-
require 'cgi'

module LJAPI
  module Models
    class Post < ActiveRecord::Base
      CENSORE = Regexp.new("\w{0,5}[х]([х\!@#\$%\^&*+-\|\/]{0,6})[у]([у\!@#\$%\^&*+-\|\/]{0,6})[ёлeеюийя]\w{0,7}|\w{0,6}[пр]([пр\!@#\$%\^&*+-\|\/]{0,6})[ие]([ие\!@#\$%\^&*+-\|\/]{0,6})[3зс]([3зс\!@#\$%\^&*+-\|\/]{0,6})[д]\w{0,10}|[с][у]([у\!@#\$%\^&*+-\|\/]{0,6})[4чк]\w{1,3}|\w{0,4}[б]([б\!@#\$%\^&*+-\|\/]{0,6})[л]([л\!@#\$%\^&*+-\|\/]{0,6})[уя]\w{0,10}|\w{0,8}[её][bб][лске@eыиаa][наи@йвл]\w{0,8}|\w{0,4}[е]([е\!@#\$%\^&*+-\|\/]{0,6})[б]([б\!@#\$%\^&*+-\|\/]{0,6})[у]([у\!@#\$%\^&*+-\|\/]{0,6})[н4ч]\w{0,4}|\w{0,4}[её]([её\!@#\$%\^&*+-\|\/]{0,6})[б]([б\!@#\$%\^&*+-\|\/]{0,6})[н]([н\!@#\$%\^&*+-\|\/]{0,6})[у]\w{0,4}|\w{0,4}[е]([е\!@#\$%\^&*+-\|\/]{0,6})[б]([б\!@#\$%\^&*+-\|\/]{0,6})[оа@]([оа@\!@#\$%\^&*+-\|\/]{0,6})[тн]\w{0,4}|\w{0,10}[ё]([ё\!@#\$%\^&*+-\|\/]{0,6})[б]\w{0,6}|\w{0,4}[pп]([pп\!@#\$%\^&*+-\|\/]{0,6})[иeе]([иeе\!@#\$%\^&*+-\|\/]{0,6})[д]([д\!@#\$%\^&*+-\|\/]{0,6})[оа@еи]([оа@еи\!@#\$%\^&*+-\|\/]{0,6})")
      VIDEO = Regexp.new("<a.*>View movie.<.*a>")

      has_no_table
      belongs_to :journal

      after_initialize :prepare

      serialize :props, OpenStruct
      column :id, :integer
      column :subject, :string
      column :text, :string
      column :published, :datetime
      column :url, :string
      column :anum, :integer
      column :replies, :integer
      column :visibility, :string
      column :commentable, :boolean
      column :last_edit, :datetime
      column :censored, :boolean
      column :has_video, :boolean

      private

      def prepare
        self.text = CGI.unescape_html(self.text)
        self.commentable = (self.props.include?('opt_nocomments') || self.props.include?('opt_lockcomments')) ? false : true
        self.last_edit = self.props.include?('revtime') ? Time.at(self.props.revtime).strftime('%Y-%m-%d %H:%M:%S') : self.created
        self.censored = CENSORE.match(self.text) ? true : false
        self.has_video = VIDEO.match(self.text) ? true : false
      end
    end
  end
end