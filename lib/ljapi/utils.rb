# -*- encoding : utf-8 -*-
module LJAPI
  class Utils
    class << self
      def time_to_ljtime(time)
        DateTime.parse(time).strftime '%Y-%m-%d %H:%M:%S'
      end

      def ljtime_to_time(str)
        dt = DateTime.strptime(str, '%Y-%m-%d %H:%M')
        Time.gm(dt.year, dt.mon, dt.day, dt.hour, dt.min, 0, 0)
      end

      def version
        v = `git describe --long`
        v.gsub('\n','')
        v
      end
    end
  end
end