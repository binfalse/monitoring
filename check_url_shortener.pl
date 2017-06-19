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
#     Monitoring URL Shortener
#     written by Martin Scharm
#       see http://binfalse.de
#
###################################
use warnings;
use strict;
use Getopt::Long;

# curl executable, you might need to change the path!?
my $curl = "/usr/bin/curl";


my $expect = "";
my $short = "";
my $respcode = 0;
my $respurl = "";
my $help = 0;

GetOptions (
	'short=s' => \$short,
	'expect=s' => \$expect,
	'help' => \$help,
	'h' => \$help);

if ($help || !-x $curl || !$short)
{
	print "$curl isn't executable...\n" unless -x $curl;
	print "need an URL (--short) to expand\n" unless $short;
	
	print "PARAMETERS:\n";
	print "\t--short \tshortened URL\n";
	print "\t--expect\texpected target redirection\n";
	print "\t--help  \tshow this msg\n";
	exit 3;
}

open CMD, "curl -s -I $short |";
while (<CMD>)
{
	if (m/^HTTP\S*\s+(\d+)/)
	{
		$respcode = $1;
		next;
	}
	if (m/^Location:\s+(\S+)\s*$/)
	{
		$respurl = $1;
		next;
	}
}
close CMD;

if ($respcode != 301)
{
	print "urgh, smth is wrong: response was $respcode, redirecting to $respurl\n";
	exit 2;
}

if ($expect && $respurl ne $expect)
{
	print "we are redirected with $respcode, but to $respurl, not as expected to $expect!?\n";
	exit 1;
}

print "redirecting works perfectly: $respcode -> $respurl\n";
exit 0;
