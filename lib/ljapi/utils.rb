# -*- encoding : utf-8 -*-
module LJAPI
  class Utils
    CENSORE = Regexp.new("\w{0,5}[х]([х\!@#\$%\^&*+-\|\/]{0,6})[у]([у\!@#\$%\^&*+-\|\/]{0,6})[ёлeеюийя]\w{0,7}|\w{0,6}[пр]([пр\!@#\$%\^&*+-\|\/]{0,6})[ие]([ие\!@#\$%\^&*+-\|\/]{0,6})[3зс]([3зс\!@#\$%\^&*+-\|\/]{0,6})[д]\w{0,10}|[с][у]([у\!@#\$%\^&*+-\|\/]{0,6})[4чк]\w{1,3}|\w{0,4}[б]([б\!@#\$%\^&*+-\|\/]{0,6})[л]([л\!@#\$%\^&*+-\|\/]{0,6})[уя]\w{0,10}|\w{0,8}[её][bб][лске@eыиаa][наи@йвл]\w{0,8}|\w{0,4}[е]([е\!@#\$%\^&*+-\|\/]{0,6})[б]([б\!@#\$%\^&*+-\|\/]{0,6})[у]([у\!@#\$%\^&*+-\|\/]{0,6})[н4ч]\w{0,4}|\w{0,4}[её]([её\!@#\$%\^&*+-\|\/]{0,6})[б]([б\!@#\$%\^&*+-\|\/]{0,6})[н]([н\!@#\$%\^&*+-\|\/]{0,6})[у]\w{0,4}|\w{0,4}[е]([е\!@#\$%\^&*+-\|\/]{0,6})[б]([б\!@#\$%\^&*+-\|\/]{0,6})[оа@]([оа@\!@#\$%\^&*+-\|\/]{0,6})[тн]\w{0,4}|\w{0,10}[ё]([ё\!@#\$%\^&*+-\|\/]{0,6})[б]\w{0,6}|\w{0,4}[pп]([pп\!@#\$%\^&*+-\|\/]{0,6})[иeе]([иeе\!@#\$%\^&*+-\|\/]{0,6})[д]([д\!@#\$%\^&*+-\|\/]{0,6})[оа@еи]([оа@еи\!@#\$%\^&*+-\|\/]{0,6})")
    VIDEO = Regexp.new("View movie")
    class << self
    # @@pattern = Regexp.new("\w{0,5}[хx]([хx\s\!@#\$%\^&*+-\|\/]{0,6})[уy]([уy\s\!@#\$%\^&*+-\|\/]{0,6})[ёiлeеюийя]\w{0,7}|\w{0,6}[пp]([пp\s\!@#\$%\^&*+-\|\/]{0,6})[iие]([iие\s\!@#\$%\^&*+-\|\/]{0,6})[3зс]([3зс\s\!@#\$%\^&*+-\|\/]{0,6})[дd]\w{0,10}|[сcs][уy]([уy\!@#\$%\^&*+-\|\/]{0,6})[4чkк]\w{1,3}|\w{0,4}[bб]([bб\s\!@#\$%\^&*+-\|\/]{0,6})[lл]([lл\s\!@#\$%\^&*+-\|\/]{0,6})[yя]\w{0,10}|\w{0,8}[её][bб][лске@eыиаa][наи@йвл]\w{0,8}|\w{0,4}[еe]([еe\s\!@#\$%\^&*+-\|\/]{0,6})[бb]([бb\s\!@#\$%\^&*+-\|\/]{0,6})[uу]([uу\s\!@#\$%\^&*+-\|\/]{0,6})[н4ч]\w{0,4}|\w{0,4}[еeё]([еeё\s\!@#\$%\^&*+-\|\/]{0,6})[бb]([бb\s\!@#\$%\^&*+-\|\/]{0,6})[нn]([нn\s\!@#\$%\^&*+-\|\/]{0,6})[уy]\w{0,4}|\w{0,4}[еe]([еe\s\!@#\$%\^&*+-\|\/]{0,6})[бb]([бb\s\!@#\$%\^&*+-\|\/]{0,6})[оoаa@]([оoаa@\s\!@#\$%\^&*+-\|\/]{0,6})[тnнt]\w{0,4}|\w{0,10}[ё]([ё\!@#\$%\^&*+-\|\/]{0,6})[б]\w{0,6}|\w{0,4}[pп]([pп\s\!@#\$%\^&*+-\|\/]{0,6})[иeеi]([иeеi\s\!@#\$%\^&*+-\|\/]{0,6})[дd]([дd\s\!@#\$%\^&*+-\|\/]{0,6})[oоаa@еeиi]([oоаa@еeиi\s\!@#\$%\^&*+-\|\/]{0,6})[рr]\w{0,12}") 
      def time_to_ljtime(time)
        DateTime.parse(time).strftime '%Y-%m-%d %H:%M:%S'
      end
      def ljtime_to_time(str)
        dt = DateTime.strptime(str, '%Y-%m-%d %H:%M')
        Time.gm(dt.year, dt.mon, dt.day, dt.hour, dt.min, 0, 0)
      end
      def check_censore(post)
        return CENSORE.match(post['event'].to_s) ? true : false
      end
      def check_video(post)
        return VIDEO.match(post['event'].to_s) ? true : false
      end
      def allow_comments(props)
        return (props.include?('opt_nocomments') || props.include?('opt_lockcomments') ? false : true)
      end
      def last_edit(props, postdate)
        if props.include?('revtime')
          updated = Time.at(props['revtime']).strftime('%Y-%m-%d %H:%M:%S').to_s
        else
          updated = postdate
        end
        return updated
      end
      def convert_urls(post, journal)
        post.update({ 'url' => "//#{journal}.livejournal.com/#{post['ditemid']}.html"})
      end
      def get_tags(props)
        tags = []
        puts props['taglist']
        tags = props['taglist'].to_s.split(',').map { |tag| tag.force_encoding('utf-8').encode.gsub(" ", "") } if props.include?('taglist')
        return tags
      end
      def version
        v = `git describe --long`
        v.gsub('\n','')
        v
      end
    end
  end
end