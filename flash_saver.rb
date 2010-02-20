#!/bin/env ruby

require 'optparse'

def log(message)
  puts message if $VERBOSE
end

def switch_screen_saver(state)
  log "switching #{state} screen saver"
  system "gconftool-2 -s /apps/gnome-screensaver/idle_activation_enabled --type bool #{state == :on}"
end

options = {}

optparse = OptionParser.new do|opts|
  opts.banner = "Usage: #$0 [options]"

  options[:wait] = 60
  opts.on( '-w', '--wait SECONDS', 'Delay between checks' ) do |seconds|
    options[:wait] = seconds.to_f
  end

  opts.on( '-v', '--verbose', 'Verbose mode' ) do
    $VERBOSE = true
  end

  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

def flash_running?
    flash_on = false
    
    %x(pgrep firefox).split.each do |pid|
        if system("grep libflashplayer /proc/#{pid}/maps > /dev/null")
            flash_on = true
        end
    end
    puts "flash running: #{flash_on}" if $VERBOSE
    
    flash_on
end

optparse.parse!

switch_screen_saver(:on)

we_turned_it_off = false

loop do
    sleep options[:wait]
    flash_on = flash_running?

    ss_on = (%x(gconftool-2 -g /apps/gnome-screensaver/idle_activation_enabled) == "true")

    if flash_on and ss_on
        switch_screen_saver(:off)
        we_turned_it_off = true
    elsif !flash_on and !ss_on and we_turned_it_off
        switch_screen_saver(:on)
        we_turned_it_off = false
    end
end
