#!/usr/bin/env ruby
# encoding: UTF-8

require "gtk2"
require "vte"
require "fileutils"

FileUtils.cd(File.dirname(__FILE__))

$pid = nil

def spawn(term, command, newline = true)
  %x[kill -9 #{$pid} 2>&1 >/dev/null] unless $pid.nil?

  if newline
    argv = ["/bin/bash", "-c", "echo -en '\n\n';" + command]
  else
    argv = ["/bin/bash", "-c", command]
  end

  $pid = term.fork_command(argv[0], argv)
  puts "Executed with pid #{$pid}"
end


#image = Gtk::Image.new("other/logo.png")

box3 = Gtk::HBox.new(true, 5)
build = Gtk::Button.new("Zbuduj")
rebuild = Gtk::Button.new("Odbuduj")
upgrade = Gtk::Button.new("Aktualizuj")
update = Gtk::Button.new("Wyślij")
status = Gtk::Button.new("Status")
stop = Gtk::Button.new("Stop")
clear = Gtk::Button.new("Wyczyść terminal")

[build, rebuild, upgrade, update, status, stop, clear].each do |widget|
  box3.add(widget)
end

#box2 = Gtk::HBox.new(false, 20)
#box2.pack_start(image, true)
#box2.pack_start(box3, false)

term = Vte::Terminal.new
term.scrollback_lines = 10000
spawn(term, "fortune | cowthink -W 80", false)

scrolled_window = Gtk::ScrolledWindow.new
scrolled_window.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_ALWAYS)
scrolled_window.add(term)

box1 = Gtk::VBox.new(false, 10)
box1.pack_start(box3, false)
box1.pack_start(scrolled_window, true)

window = Gtk::Window.new
window.title = "WeirdScience Launcher"
window.border_width = 10
window.resize(800, 600)
window.add(box1)


window.signal_connect('delete_event') do
  Gtk.main_quit
  false
end

build.signal_connect("clicked") do |w|
  spawn(term, "php main.php5")
end

rebuild.signal_connect("clicked") do |w|
  spawn(term, "rm -r Projekt/tmp Projekt/output Projekt/index.xml; php main.php5")
end

upgrade.signal_connect("clicked") do |w|
  spawn(term, "git pull")
end

update.signal_connect("clicked") do |w|
  spawn(term, "ruby upload.rb")
end

status.signal_connect("clicked") do |w|
  spawn(term, "ruby upload.rb status")
end

stop.signal_connect("clicked") do |w|
  spawn(term, "echo Wykonanie zatrzymane.", false)
end

clear.signal_connect("clicked") do |w|
  term.reset(true, true)
  spawn(term, "fortune | cowthink -W 80", false)
end

window.show_all
Gtk.main
