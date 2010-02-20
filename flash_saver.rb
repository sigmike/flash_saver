#!/bin/env ruby

# Cleanup any bad state we left behind if the user exited while flash was
# running
system "gconftool-2 -s /apps/gnome-screensaver/idle_activation_enabled --type bool true"

we_turned_it_off = false

loop do
    sleep 60
    flash_on = false

    %x(pgrep firefox).split.each do |pid|
        if system("grep libflashplayer /proc/#{pid}/maps > /dev/null")
            flash_on = true
        end
        
        ss_on = (%x(gconftool-2 -g /apps/gnome-screensaver/idle_activation_enabled) == "true")

        if flash_on and ss_on
            system "gconftool-2 -s /apps/gnome-screensaver/idle_activation_enabled --type bool false"
            we_turned_it_off = true
        elsif !flash_on and !ss_on and we_turned_it_off
            system "gconftool-2 -s /apps/gnome-screensaver/idle_activation_enabled --type bool true"
            we_turned_it_off = false
        end
    end
end
