# encoding: UTF-8

require 'logger'


module AirSyncInstaller


  class InstallerLogger
    OUTPUT_DIR = "InstallerLogs"
    TXT_RESET = "\e[0m"
    TXT_RED = "\e[0;1;4;31m"
    TXT_GREEN = "\e[0;1;32m"
    TXT_YELLOW = "\e[0;1;33m"
    TXT_GRAY = "\e[0m"


    def initialize(name = "installer")
      name = name + " " + Time.now.strftime("%Y-%m-%d %H:%M:%S")
      @output_path = File.join(OUTPUT_DIR, "#{name}.log")

      @myLogger = Logger.new(@output_path, 5, 10*1024)
    end


    def info(data)
      puts TXT_RESET + time + " " + TXT_GREEN + "II: " + data + TXT_RESET
      @myLogger.info data
    end


    def err(data)
      puts TXT_RESET + time + " " + TXT_RED + "EE: " + data + TXT_RESET
      @myLogger.error data
    end


    def warn(data)
      puts TXT_RESET + time + " " + TXT_YELLOW + "WW: " + data + TXT_RESET
      @myLogger.warn data
    end


    def debug(data)
      puts TXT_RESET + time + " " + TXT_GRAY + "DD: " + data + TXT_RESET
      @myLogger.debug data
    end


    def time
      Time.now.strftime("%H:%M:%S")
    end

  end

end
