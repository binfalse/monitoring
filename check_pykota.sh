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
#     check if pykota is available.
#     especially helpful if somebody
#     updated python...
#     written by Martin Scharm
#       see http://binfalse.de
#
###################################

source /usr/lib/nagios/plugins/utils.sh

# nagios should be able to sudo on /usr/bin/pykotme
sudo /usr/bin/pykotme > /dev/null 2>&1

if [ $? -ne 0 ] 
then
	echo -e 'ERROR WITH PYKOTA!! Please check it'
	exit $STATE_CRITICAL
else
	echo -e 'PYKOTA-check ok!'
	exit $STATE_OK
fi

