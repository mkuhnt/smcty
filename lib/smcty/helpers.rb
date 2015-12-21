module Smcty

  def natural_time(time)
    unit = time

    # given unit in seconds
    hours = unit / 3600
    unit = unit - (hours * 3600)

    minutes = unit / 60
    seconds = unit - (minutes * 60)

    result =  (hours > 0) ? "#{hours}h " : ""
    result += (minutes > 0) ? "#{minutes}m " : ""
    result += "#{seconds}s"

    result.strip
  end

end
