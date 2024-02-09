#!/bin/bash
# Copyright (C) 2017 Martin Scharm <https://binfalse.de/contact/>
#
# This file is part of bf-monitoring.
# <https://binfalse.de/software/nagios/>
# <https://github.com/binfalse/monitoring>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


# this script checks if the file /var/run/reboot-required is present
# should work on all debian-based systems...


if [ -f "/var/run/reboot-required" ]
then
    echo "reboot required!"
    exit 1
fi

if [ -f "/usr/sbin/needrestart" ]
then
    /usr/sbin/needrestart -p
else
    echo "looks good over here..."
    exit 0
fi



