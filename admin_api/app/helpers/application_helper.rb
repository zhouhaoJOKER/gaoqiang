module ApplicationHelper


  def bst(time)
    time.in_time_zone("#{Setting.time_zone}").strftime("%Y-%m-%d %H:%M:%S") rescue time
  end

  def bt(time)
    time.in_time_zone("#{Setting.time_zone}").strftime("%Y-%m-%d") rescue  time
  end
end
