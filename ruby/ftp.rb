
require 'net/ftp'


class FtpWrapper
  INJ_ROOT = "inpt"
  EJECT_ROOT = "ejp"


  def initialize(addr, login, passwd, logger=nil)
    @max_attempts = 5
    @attempts_sleep = 5

    @ftp = nil
    @logger = logger

    @addr = addr
    @login = login
    @passwd = passwd

    connect
  end


  def connect
    attempts = 0

    begin
      @logger.debug("connecting to FTP (ftp://#{@login}:#{@passwd}@#{@addr}:21)")

      timeout(30) do
        @ftp = Net::FTP.new(@addr) if @ftp.nil?
      end

      @ftp.passive = true
      @ftp.login(@login, @passwd)
    rescue  Net::FTPError => details
      attempts += 1
        if attempts < @max_attempts
          @logger.warn("ftp: could not connect to remote host; next attempt in #{@attempts_sleep} seconds")
          sleep @attempts_sleep
          @ftp = nil
          retry
        else
          @logger.err("ftp: could not connect to remote host")
          raise
        end
    rescue Exception => details
      @logger.err(details.message + "\n\n" + details.backtrace.join("\n"))
    end
  end


  def close
    @logger.debug("ftp: closing FTP connection (ftp://#{@login}:#{@passwd}@#{@addr}:21)")
    unless @ftp.nil?
      @ftp.close unless @ftp.closed?
    end
  end


  def check_connection
    unless @ftp.nil?
      begin
        timeout(5) do
          @ftp.noop
        end
      rescue
        @ftp.close
        @ftp = nil
      end
    end

    if @ftp.nil? || @ftp.closed?
      @logger.warn("ftp: FTP connection lost, trying to reconnect")
      connect
    end
  end


  def put_directory(local, remote)
    begin
      chdir(remote, true)

      Dir.new(local).each do |file|
        putbinaryfile(File.join(local, file), file)
      end

    rescue
      @logger.err("ftp: error during directory upload")
      raise Net::FTPError, "ftp: error during directory upload"
    end
  end


  def get_directory(remote, local)
    begin
      chdir(remote)

      list.each do |f_name|
        get(f_name, File.join(local, f_name))
      end

    rescue
      @logger.err("ftp: error during directory download")
      raise Net::FTPError, "ftp: error during directory download"
    end
  end


  def put_files(local_dir, remote_dir, files)
    begin
      chdir(remote_dir, true)

      files.each do |file|
        putbinaryfile(File.join(local_dir, file), file)
      end

    rescue
      @logger.err("ftp: error during multiple files upload")
      raise Net::FTPError, "ftp: error during multiple files upload"
    end
  end


  def get_files(remote_dir, local_dir, files)
    begin
      chdir(remote_dir, false)

      files.each do |file|
        get(file, File.join(local_dir, file))
      end

    rescue
      @logger.err("ftp: error during multiple files download")
      raise Net::FTPError, "ftp: error during multiple files download"
    end
  end


  def chdir(path, create = false)
    attempts = 0

    @logger.debug("ftp: changing working directory to \"#{path}\"")
    begin
      check_connection
      @ftp.chdir(path)
    rescue Exception => e
      attempts += 1
        if attempts < @max_attempts
          if create
            @logger.warn("ftp: cwd failed (#{e.message.strip.chomp}); trying to create directory")
            begin
              @ftp.mkdir(path)
              @logger.debug("ftp: directory created")
              retry
            rescue
              @logger.warn("ftp: create directory failed (#{e.message.strip.chomp})")
            end
          end
          @logger.warn("ftp: cwd failed (#{e.message.strip.chomp}); next attempt in #{@attempts_sleep} seconds...")
          sleep @attempts_sleep
          retry
        else
          @ftp.chdir("/")
          @logger.err("ftp: cwd failed")
          raise Net::FTPError, "ftp: cwd failed"
        end
    end
    begin
      dir = @ftp.pwd
      @logger.debug("ftp: current working directory is \"#{dir}\"")
    rescue
      @logger.err("ftp: current working directory is unknown")
    end
  end


  def delete(path)
    attempts = 0

    @logger.debug("ftp: deleting file  \"#{path}\"")
    begin
      check_connection
      @ftp.delete(path)
    rescue Exception => e
      attempts += 1

      if attempts < @max_attempts
        @logger.warn("ftp: deleting failed (#{e.message.strip.chomp}); next attempt in #{@attempts_sleep} seconds...")
        sleep @attempts_sleep
        retry
      else
          @logger.err("ftp: deleting failed")
          raise Net::FTPError, "ftp: deleting failed"
      end
    end
  end


  def list
    attempts = 0

    @logger.debug("ftp: getting file list")
    begin
      check_connection
      result = @ftp.nlst()
    rescue Exception => e
      attempts += 1

      if attempts < @max_attempts
        @logger.warn("ftp: getting file list failed (#{e.message.strip.chomp}); next attempt in #{@attempts_sleep} seconds...")
        sleep @attempts_sleep
        retry
      else
          @logger.err("ftp: getting file list failed")
          raise Net::FTPError, "ftp: getting file list failed"
      end
    end

    return result
  end


  # Sends file "local" to server. If operation is unsuccessful, takes
  # 2 additional attempts, then raises exception. If file is not metadata,
  # this method won't overwrite it.
  def putbinaryfile(local, remote)
    attempts = 0

    @logger.debug("ftp: sending file \"#{remote}\" from \"#{local}\" (binary)")
    begin
      check_connection
      @ftp.putbinaryfile(local, remote, 8192)
    rescue Exception => e
      attempts += 1
        if attempts < @max_attempts
          if e.message[0..2] == "553" && remote !~ /metadata\.xml$/
            @logger.warn("ftp: sending failed (#{e.message.strip.chomp}); not metadata, checking if already exists")
            begin
              @ftp.get(remote, "/dev/null")
              @logger.debug("ftp: check successful")
              return
            rescue Exception => e
              @logger.warn("ftp: check failed (#{e.message.strip.chomp}), resending in #{@attempts_sleep} seconds...")
              sleep @attempts_sleep
            end
          else
            @logger.warn("ftp: sending failed (#{e.message.strip.chomp}); next attempt in #{@attempts_sleep} seconds...")
            sleep @attempts_sleep
          end

          retry
        else
          @logger.err("ftp: sending failed")
          raise Net::FTPError, "ftp: sending failed"
        end
    end
  end


  def get(remote, local)
    attempts = 0
    @logger.debug("ftp: receiving file \"#{local}\" from \"#{remote}\"")

    begin
      check_connection
      @ftp.get(remote, local)
    rescue Exception => e
      attempts += 1
        if attempts < @max_attempts
          @logger.warn("ftp: receiving failed (#{e.message.strip.chomp}); next attempt in #{@attempts_sleep} seconds...")
          sleep @attempts_sleep
          retry
        else
          @logger.err("ftp: receiving failed")
          raise Net::FTPError, "ftp: receiving failed"
        end
    end
  end


  def mkdir(remote)
    attempts = 0
    @logger.debug("ftp: creating directory \"#{remote}\"")

    begin
      check_connection
      @ftp.mkdir(remote)
    rescue Exception => e
      attempts += 1
        if attempts < @max_attempts
          @logger.warn("ftp: creating directory failed (#{e.message.strip.chomp}); next attempt in #{@attempts_sleep} seconds...")
          sleep @attempts_sleep
          retry
        else
          @logger.err("ftp: creating directory failed")
          raise Net::FTPError, "ftp: creating directory failed"
        end
    end
  end


  def file_exists?(path)
    begin
      check_connection
      @ftp.size(path)
      return true
    rescue
      return false
    end
  end


  def dir_exists?(path)
    begin
      check_connection
      @ftp.chdir(path)
      return true
    rescue
      return false
    end
  end


  def timeout(t = 5)
    th1, th2 = nil

    th1 = Thread.new do
      yield

      th2.kill if th2.alive?
    end

    th2 = Thread.new do
      sleep t

      if th1.alive?
        th1.kill
        raise Net::FTPError, "ftp: timeout"
      end
    end

    th1.join
    th2.join
  end

end
