module Utils
  def self.time_to_ljtime(time)
    time.strftime '%Y-%m-%d %H:%M:%S'
  end
  def self.ljtime_to_time(str)
    dt = DateTime.strptime(str, '%Y-%m-%d %H:%M')
    Time.gm(dt.year, dt.mon, dt.day, dt.hour, dt.min, 0, 0)
  end
end