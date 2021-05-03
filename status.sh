#!/usr/local/bin/bash

# Display system information in statusbar of DWM
# This script is combining shell re-write of
##  freebsd-memory -- List Total System Memory Usage
##  Copyright (c) 2003-2004 Ralf S. Engelschall <rse@engelschall.com>
## http://www.cyberciti.biz/files/scripts/freebsd-memory.pl.txt
##  Copyright (c) 2015 Olivier Cochard-Labbé <olivier@freebsd.org>
## (https://github.com/ocochard/myscripts/blob/master/FreeBSD/freebsd-memory.sh)
# And https://github.com/anselal/homeunix/blob/master/.dwm/autostart.sh
# To accurately follow the states available from acpiconf
# and display memory info


# HELPER FUNCTIONS FOR MEMORY
mem_rounded () {
    mem_size=$1
    chip_size=1
    chip_guess=`echo "$mem_size / 8 - 1" | bc`
    while [ $chip_guess != 0 ]
        do
                chip_guess=`echo "$chip_guess / 2" | bc`
                chip_size=`echo "$chip_size * 2" | bc`
    done
    mem_round=`echo "( $mem_size / $chip_size + 1 ) * $chip_size" | bc`
    echo $mem_round
        exit 0
}

free_memory () {
        #   determine the individual known information
        #   NOTICE: forget hw.usermem, it is just (hw.physmem - vm.stats.vm.v_wire_count).
        #   NOTICE: forget vm.stats.misc.zero_page_count, it is just the subset of
        #           vm.stats.vm.v_free_count which is already pre-zeroed.
        mem_phys=`sysctl -n hw.physmem`
        set +e
        mem_hw=`mem_rounded $mem_phys`
        set -e
        sysctl_pagesize=`sysctl -n hw.pagesize`
        mem_all=`echo "\`sysctl -n vm.stats.vm.v_page_count\` \
	* $sysctl_pagesize" | bc`
        mem_wire=`echo "\`sysctl -n vm.stats.vm.v_wire_count\` \
	* $sysctl_pagesize" | bc`
        mem_active=`echo "\`sysctl -n vm.stats.vm.v_active_count\` \
	* $sysctl_pagesize" | bc`
        mem_inactive=`echo "\`sysctl -n vm.stats.vm.v_inactive_count\` \
	* $sysctl_pagesize" | bc`
        mem_cache=`echo "\`sysctl -n vm.stats.vm.v_cache_count\` \
	* $sysctl_pagesize" | bc`
        mem_free=`echo "\`sysctl -n vm.stats.vm.v_free_count\` \
	* $sysctl_pagesize" | bc`

        #   determine logical summary information
        mem_total=$mem_hw
        mem_avail=`echo "$mem_inactive + $mem_cache + $mem_free" | bc`
        mem_used=`echo "$mem_total - $mem_avail" | bc`

        #   print system results
        mem_mb=`echo "$mem_used / ( 1024 * 1024 )" | bc`
        if [ $mem_mb -lt 1000 ]; then
            printf "R: %7dMB [%3d%%]" \
	`echo "$mem_used / ( 1024 * 1024 )" | bc` `echo "$mem_used \
	* 100 / $mem_total" | bc`
        else
            printf "R: %.2fGB [%3d%%]" \
	`echo "$mem_used / ( 1024 * 1024 * 1024 )" | bc -l` `echo "$mem_used \
	* 100 / $mem_total" | bc`
        fi
}

avg_load() {
    AVG_LOAD=`uptime | awk -F'[a-z]:' '{ print $2 }'`
    echo "L:$AVG_LOAD"
}

dte() {
    echo $(date +"%I:%M%p %a %b %d %G")
}

battery() {

    CAPACITY1=`acpiconf -i 0 | grep 'Remaining capacity:' | cut -f2 | sed s/%//`
    CAPACITY2=`acpiconf -i 1 | grep 'Remaining capacity:' | cut -f2 | sed s/%//`
    TIME1=`acpiconf -i 0 | grep 'Remaining time:' | cut -f3`
    TIME=`acpiconf -i 1 | grep 'Remaining time:' | cut -f3`
    STATE1=`acpiconf -i 0 | grep 'State:' | cut -f4`
    STATE=`acpiconf -i 1 | grep 'State:' | cut -f4`

    CAPACITY=$(printf "%.0f" `echo "$CAPACITY1 + $CAPACITY2 - 100" | bc`)

    if [ $STATE == "discharging" ]; then
        STATE="-"
    elif [ $STATE == "charging" ]; then
        STATE="+"
    elif [ $STATE == "high" ]; then
        STATE="="
    elif [ $STATE == "critical" ]; then
        STATE="!!"
    else
	STATE="~"
    fi

    if [ $STATE == "-" ]; then
        echo "B: $CAPACITY% [$STATE] ($TIME)"
    else
        echo "B: $CAPACITY% [$STATE]"
    fi
}

brand() {
    BRAND=$'\uf30c'
    echo $BRAND
}

while true; do
    xsetroot -name  " $(free_memory) | $(battery) | $(dte) | $(brand)"
    sleep 1
done &
