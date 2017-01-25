#!/usr/bin/perl -w
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
#  Check the state of mount points
#     written by Martin Scharm
#       see http://binfalse.de
#
###################################

use warnings;
use strict;
use Getopt::Long qw(:config no_ignore_case);
use lib '/usr/lib/nagios/plugins';
use utils qw(%ERRORS);

my $MOUNT = undef;
my $TYPE = undef;

sub how_to
{
	print "USAGE: $0\n\t-m MOUNTPOINT\twich mountpoint to check\n\t[-t TYPE]\toptionally check whether it's this kind of fs-type\n\n";
}

GetOptions (
		'm=s' => \ $MOUNT,
		'mountpoint=s' => \ $MOUNT,
		't=s' => \ $TYPE,
		'type=s' => \ $TYPE
	   );

unless (defined ($MOUNT))
{
	print "Please define mountpoint\n\n";
	how_to;
	exit $ERRORS{'CRITICAL'};
}

my $erg = `/bin/mount | /bin/grep $MOUNT`;

if ($erg)
{
	if (defined ($TYPE))
	{
		if ($erg =~ m/type $TYPE /)
		{
			print $MOUNT . " is mounted! Type is " . $TYPE . "\n";
			exit $ERRORS{'OK'};
		}
		else
		{
			print $MOUNT . " is mounted! But type is not " . $TYPE . "\n";
			exit $ERRORS{'WARNING'};
		}
	}
	print $MOUNT . " is mounted!\n";
	exit $ERRORS{'OK'};
}
else
{
	print $MOUNT . " is not mounted!\n";
	exit $ERRORS{'CRITICAL'};
}

