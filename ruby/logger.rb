

class Logger
  TXT_RESET = "\e[0m"
  TXT_RED = "\e[0;1;4;31m"
  TXT_GREEN = "\e[0;32m"
  TXT_YELLOW = "\e[0;1;33m"
  TXT_GRAY = "\e[0m"


  def initialize
    @start = Time.now
  end


  def info(data)
    puts TXT_RESET + time + " " + TXT_GREEN + "II: " + data + TXT_RESET
  end


  def err(data)
    puts TXT_RESET + time + " " + TXT_RED + "EE: " + data + TXT_RESET
  end


  def warn(data)
    puts TXT_RESET + time + " " + TXT_YELLOW + "WW: " + data + TXT_RESET
  end


  def debug(data)
    #puts TXT_RESET + time + " " + TXT_GRAY + "DD: " + data + TXT_RESET
  end


  def time
    delta = Time.now - @start
    return "[%011.6f]" % delta
  end

end