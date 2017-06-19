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
#     Check if there are pending Backups
#     written by Martin Scharm
#       see http://binfalse.de
#
#     tested with v8.60
#
###################################

source /usr/lib/nagios/plugins/utils.sh

#############
# ARGUMENTS:
#############

# maximum number of stored backups, if this value is exceeded we'll warn
MAX=${1}



#############
# CONFIG:
#############

# please take care of paths!!

# where are backups located
BACKUPDIR=/var/backups/sysbackups

# error log file
ERRLOG=${BACKUPDIR}/backup.err


################################################################################
# thats it... don't change anything below unless you know what you're doing... #
################################################################################

PENDING=$(/bin/ls ${BACKUPDIR} | /bin/grep snapshot | /usr/bin/wc -l)
ERRORS=0

crit=""
warn=""

if [ -f ${ERRLOG} ]
then
        ERRORS=$(/bin/cat ${ERRLOG} | /bin/grep -v "tar: Removing leading" | /usr/bin/wc -l)
else
        warn="${warn} error log not present. path correct?"
fi

if [ ${MAX} -lt ${PENDING} ]; then
        crit="${crit} please download and clean up!"
fi

if [ ${ERRORS} -gt 0 ]
then
        crit="${crit} please deal with errors!"
fi


if [ -n "${crit}" ]
then
        echo "${PENDING} backups pending... ${ERRORS} errors! ${crit} ${warn}"
        exit ${STATE_CRITICAL}
fi

if [ -n "${warn}" ]
then
        echo "${PENDING} backups pending... ${ERRORS} errors! ${crit} ${warn}"
        exit ${STATE_WARNING}
fi


echo "${PENDING} backups pending... ${ERRORS} errors. that's ok..."
exit ${STATE_OK}

