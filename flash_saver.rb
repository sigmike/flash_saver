#!/bin/env ruby

require 'optparse'

def log(message)
  puts message if $VERBOSE
end

def switch_screen_saver(state)
  log "switching #{state} screen saver"
  system "gconftool-2 -s /apps/gnome-screensaver/idle_activation_enabled --type bool #{state == :on}"
end

def flash_running?
  resolution = %x(xrandr).split("\n").grep(/\*/).first.split.first
  
  window_infos = %x(xwininfo -all -root)
  
  firefox_resolutions = window_infos.scan(/"Firefox": \("firefox" "Firefox"\)\s+(\d+x\d+)\+0\+0  \+0\+0/)
  firefox_resolutions.flatten!
  
  if firefox_resolutions.include? resolution
    flash_on = true
  else
    flash_on = false
  end

  puts "flash running: #{flash_on}" if $VERBOSE
  
  flash_on
end

def screen_saver_active?
  (%x(gconftool-2 -g /apps/gnome-screensaver/idle_activation_enabled).strip == "true")
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

optparse.parse!

switch_screen_saver(:on)

begin
  loop do
    flash_on = flash_running?
    ss_on = screen_saver_active?

    if flash_on and ss_on
      switch_screen_saver(:off)
    elsif !flash_on and !ss_on
      switch_screen_saver(:on)
    end

    sleep options[:wait]
  end
ensure
  switch_screen_saver(:on)
end
