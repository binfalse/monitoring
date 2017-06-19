#!/bin/bash
#
# Copyright 2009-2017 Martin Scharm
#
# This file is part of bf-monitoring.
# <https://binfalse.de/software/nagios/>
# <https://github.com/binfalse/monitoring>
#
# bf-monitoring is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# bf-monitoring is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# bf-monitoring If not, see <http://www.gnu.org/licenses/>.
#
###################################
#
#     Check if the system is running the latest kernel
#     or if a reboot is necessary
#
#     by Martin Scharm <https://binfalse.de/contact>
#
#
###################################

source /usr/lib/nagios/plugins/utils.sh



current_kernel=$(uname -r)
latest_kernel=$(find /boot/ -name vmlinuz-* | sort -V | tail -1 | sed 's/.*vmlinuz-//')

# no uname?
if [ -z "$current_kernel" ]
then
    echo "uname returns empty string?"
    exit ${STATE_CRITICAL}
fi


# no /boot/vmlinuz-* ?
if [ -z "$latest_kernel" ]
then
    echo "no /boot/vmlinuz-* found.."
    exit ${STATE_CRITICAL}
fi


# compare the strings
if [ "$current_kernel" = "$latest_kernel" ]
then
    echo "running kernel is $current_kernel"
    exit ${STATE_OK}
else
    echo "your kernel $current_kernel is outdated, please boot into $latest_kernel"
    exit ${STATE_WARNING}
fi

