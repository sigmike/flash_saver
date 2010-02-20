#!/bin/env ruby

require 'optparse'

def log(message)
  puts message if $VERBOSE
end

def debug(message)
  puts message if $DEBUG
end


def run(command)
  debug "Running #{command.inspect}"
  system command
end

def switch_screen_saver(state)
  if state == :on
    log "Switching screen saver on"
    run "gconftool-2 -s /apps/gnome-screensaver/idle_activation_enabled --type bool true"
    run "xset s on"
    run "xset +dpms"
  else
    log "Switching screen saver off"
    run "gconftool-2 -s /apps/gnome-screensaver/idle_activation_enabled --type bool false"
    run "xset s off"
    run "xset -dpms"
  end
end

def poke_screensaver
  log "Simulating user activity"
  run "gnome-screensaver-command -p"
end

def flash_running?
  resolution = %x(xrandr).split("\n").grep(/\*/).first.split.first
  debug "Current resolution: #{resolution.inspect}"
  
  window_infos = %x(xwininfo -all -root)
  
  firefox_resolutions = window_infos.scan(/"Firefox": \("firefox" "Firefox"\)\s+(\d+x\d+)\+0\+0  \+0\+0/)
  firefox_resolutions.flatten!
  debug "Firefox resolutions: #{firefox_resolutions.inspect}"
  
  firefox_resolutions.include? resolution
end

def screen_saver_active?
  command = "gconftool-2 -g /apps/gnome-screensaver/idle_activation_enabled"
  result = %x(#{command}).strip
  debug "Running #{command.inspect} => #{result.inspect}"
  result == "true"
end

options = {}

optparse = OptionParser.new do|opts|
  opts.banner = "Usage: #$0 [options]"

  options[:wait] = 30
  opts.on( '-w', '--wait SECONDS', "Delay between checks (default: #{options[:wait]})" ) do |seconds|
    options[:wait] = seconds.to_f
  end

  opts.on( '-v', '--verbose', 'Verbose mode' ) do
    $VERBOSE = true
  end

  opts.on( '-d', '--debug', 'Debug mode' ) do
    $DEBUG = true
  end

  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

optparse.parse!

loop do
  if flash_running?
    poke_screensaver
  end

  sleep options[:wait]
end
