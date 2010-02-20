#!/bin/bash

# Cleanup any bad state we left behind if the user exited while flash was
# running
gconftool-2 -s /apps/gnome-screensaver/idle_activation_enabled --type bool true

we_turned_it_off=0

while true; do
    sleep 60
    flash_on=0

    for pid in `pgrep firefox` ; do
        if grep libflashplayer /proc/$pid/maps > /dev/null ; then
            flash_on=1
        fi
        
        ss_on=`gconftool-2 -g /apps/gnome-screensaver/idle_activation_enabled`

        if [ "$flash_on" = "1" ] && [ "$ss_on" = "true" ]; then
            gconftool-2 -s /apps/gnome-screensaver/idle_activation_enabled \
                --type bool false
            we_turned_it_off=1
        elif [ "$flash_on" = "0" ] && [ "$ss_on" = "false" ] \
                && [ "$we_turned_it_off" = "1" ]; then
            gconftool-2 -s /apps/gnome-screensaver/idle_activation_enabled \
                --type bool true
            we_turned_it_off=0
        fi

    done
done
