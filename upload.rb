#!/usr/bin/ruby
# encoding: UTF-8

require 'yaml'
require 'fileutils'
require 'digest/md5'

require './ruby/logger'
require './ruby/ftp'


begin

  class Uploader

    def initialize
      @logger = Logger.new
      @ftp = nil

      config = YAML::load(File.open("ftp.config"))

      tmp = config["url"].split("@")
      credentials, address = tmp[0..-2].join("@"), tmp.last
      @login, @password = credentials.split(":")
      @host, @port = address.split(":")

      if @port.include?("/")
        pos = @port =~ /\//
        @ftp_root = @port[pos..-1]
        @port = @port[0..pos-1]
      else
        @ftp_root = "/"
      end

      @checkout = config["checkout"]
      @data = config["data"]

      @logger.info("host: #{@host}")
      @logger.info("login: #{@login}")
      @logger.info("password: #{@password}")
      @logger.info("checkout: #{@checkout}")
      @logger.info("ftp_root: #{@ftp_root}")

      @ftp = nil
    end


    def connect(dummy = false)
      @ftp = FtpWrapper.new(@host, @login, @password, @logger) unless dummy
    end


    def disconnect
	    @ftp.close unless @ftp.nil?
    end


    def remove_dir(path)
      Dir.new(path).each do |name|
        next if name =~ /^\./

        if File.directory?(File.join(path, name))
          remove_dir(File.join(path, name))
        else
          File.unlink(File.join(path, name))
        end
      end
      Dir.rmdir(path)
    end


    def checkout_proc(remote, local)
      @ftp.chdir(remote)

      if File.directory?(local)
        remove_dir(local)
      end

      Dir.mkdir(local)

      @ftp.list.each do |path|
        next if path =~ /^\./

        local_path = File.join(local, path)

        if @ftp.file_exists?(path)
          @logger.info("Pobieranie pliku \"#{local_path}\"")
          @ftp.get(path, local_path)
        else
          checkout_proc(path, local_path)
        end
      end

      @ftp.chdir("..")
    end

    def checkout
      connect
      checkout_proc(@ftp_root, @checkout)
      disconnect
    end


    def scan(path, prefix = path)
      @logger.info("Skanowanie #{path}")
      result = []

      Dir.new(path).each do |name|
        next if name =~ /^\./

        npath = File.join(path, name)
        spath = npath.sub(prefix, "")

        if File.directory?(npath)
          result += [{ :type => :directory, :path => spath }]
          result += scan(npath, prefix)
        else
          result += [{ :type => :file, :path => spath }]
        end
      end

      return result
    end


    def ndec(n, one, tofour, rest)
      return "#{n} #{one}" if n == 1
      return "#{n} #{tofour}" if (n % 10 >= 2) && (n % 10 <= 4) && ((n % 100 < 10) || (n % 100 > 20))
      return "#{n} #{rest}"
    end


    def status
      @logger.info("Sprawdzanie statusu repozytorium")

      on_ftp = scan(@checkout)
      on_data = scan(@data)

      @logger.info("Ogółem #{ndec(on_data.length, 'plik', 'pliki', 'plików')}")

      to_send = on_data.select do |file|
        !on_ftp.include?(file) ||
        !File.directory?(File.join(@checkout, file[:path])) &&
        Digest::MD5.file(File.join(@checkout, file[:path])) != Digest::MD5.file(File.join(@data, file[:path]))
      end

      @logger.info("#{ndec(to_send.length, 'plik', 'pliki', 'plików')} do wysłania")

      to_delete = on_ftp.select do |file|
         !on_data.include?(file)
      end

      @logger.info("#{ndec(to_delete.length, 'plik', 'pliki', 'plików')} do usunięcia")

      return [to_send, to_delete]
    end


    def commit
      @logger.info("Aktualizacja repozytorium")

      to_send, to_delete = status

      if to_send.empty? && to_delete.empty?
        @logger.info("Nie ma nic do zrobienia")
        return
      end

      connect

      @logger.info("Wysyłanie plików")

      to_send.each do |file|
        if file[:type] == :directory
          @logger.info("Tworzenie katalogu \"#{file[:path]}\"")
          @ftp.mkdir(File.join(@ftp_root, file[:path]))
          Dir.mkdir(File.join(@checkout, file[:path]))
        else
          @logger.info("Wysyłanie pliku \"#{file[:path]}\"")
          @ftp.putbinaryfile(File.join(@data, file[:path]), File.join(@ftp_root, file[:path]))
          FileUtils.cp(File.join(@data, file[:path]), File.join(@checkout, file[:path]))
        end
      end

      @logger.info("Usuwanie zbędnych plików")

      to_delete.each do |file|
        @logger.info("Usuwanie pliku #{file[:path]}")
        @ftp.delete(File.join(@ftp_root, file[:path]))
        File.unlink(File.join(@checkout, file[:path]))
      end

      disconnect

      @logger.info("Wysyłanie zakończone")
    end

  end


uploader = Uploader.new

case ARGV[0]
  when "checkout" then uploader.checkout
  when "status" then uploader.status
  else uploader.commit
end

rescue Exception => e
  puts e.message
  puts e.backtrace.join("\n")
end
