#!/usr/bin/perl -w
#################################################
#
#     Monitor FANS of an extreme networks device
#     written by Martin Scharm
#       see http://binfalse.de
#     modified for SNMPv3 by Benjamin Gauß
#
#################################################

use strict;
use Net::SNMP;
use Getopt::Long;

use lib "/usr/lib64/nagios/plugins/";
use utils qw($TIMEOUT %ERRORS);

my $FANTABLE = '1.3.6.1.4.1.1916.1.1.1.9.1';
my $FAN_DEV = '1';
my $FAN_STATE = '2';
my $FAN_SPEED = '4';


my $returnvalue = $ERRORS{"OK"};
my $returnstring = "";
my $returnsupp = "";

my $switch = undef;
my $username = undef;
my $authpassword = undef;
my $authprotocol = undef;
my $privpassword = undef;
my $privprotocol = undef;
my $help = undef;

Getopt::Long::Configure ("bundling");
GetOptions(
	'h' => \$help,
	'help' => \$help,
	's:s' => \$switch,
	'switch:s' => \$switch,
	'U:s' => \$username,
	'user:s' => \$username,
	'A:s' => \$authpassword,
	'authpassword:s' => \$authpassword,
	'a:s' => \$authprotocol,
	'authprotocol:s' => \$authprotocol,
	'P:s' => \$privpassword,
	'privpassword:s' => \$privpassword,
	'p:s' => \$privprotocol,
	'privprotocol:s' => \$privprotocol,
	'T:s' => \$TIMEOUT,
	'timeout:s' => \$TIMEOUT
);

sub print_usage
{
    print "Usage: $0 -s <SWITCH> -U <USER> -A <AUTH-PASSWORD> -a <AUTH-PROTOCOL> -P <PRIV-PASSWORD> -p <PRIV-PROTOCOL> [-T <TIMEOUT>]\n\n";
    print "       <SWITCH>            the switch's hostname or ip address\n";
    print "       <USER>              the SNMPv3 username\n";
    print "       <AUTH-PASSWORD>     the password for SNMPv3 authentication\n";
    print "       <AUTH-PROTOCOL>     the protocol for SNMPv3 authentication\n";
    print "       <PRIV-PASSWORD>     the privacy password for SNMPv3 data transport\n";
    print "       <PRIV-PROTOCOL>     the privacy protocol for SNMPv3data transport\n";
    print "       <TIMEOUT>           max time to wait for an answer, defaults to ".$TIMEOUT."\n"
}


# CHECKS
if ( defined($help) )
{
	print_usage();
	exit $ERRORS{"UNKNOWN"};
}
if ( !defined($switch) )
{
	print "Need switch address!\n";
	print_usage();
	exit $ERRORS{"UNKNOWN"};
}
if ( !defined($username) )
{
	print "Need SNMPv3 username!\n";
	print_usage();
	exit $ERRORS{"UNKNOWN"};
}
if ( !defined($authpassword) )
{
        print "Need SNMPv3 authentication password!\n";
        print_usage();
        exit $ERRORS{"UNKNOWN"};
}
if ( !defined($authprotocol) )
{
        print "Need SNMPv3 authentication protocol!\n";
        print_usage();
        exit $ERRORS{"UNKNOWN"};
}
if ( !defined($privpassword) )
{
        print "Need SNMPv3 privacy password!\n";
        print_usage();
        exit $ERRORS{"UNKNOWN"};
}
if ( !defined($privprotocol) )
{
        print "Need SNMPv3 privacy protocol!\n";
        print_usage();
        exit $ERRORS{"UNKNOWN"};
}


my ($session, $error) = Net::SNMP->session( -hostname  => $switch, -version   => 3, -username  => $username, -authpassword => $authpassword, -authprotocol => $authprotocol, -privpassword => $privpassword, -privprotocol => $privprotocol, -timeout   => $TIMEOUT);

if (!defined($session)) {
   printf("ERROR opening session: %s.\n", $error);
   exit $ERRORS{"CRITICAL"};
}
my $fan_table = $session->get_table(-baseoid => $FANTABLE);
if (!defined($fan_table))
{
   printf("ERROR: Description table : %s.\n", $session->error);
   $session->close;
   exit $ERRORS{"CRITICAL"};
}

# building the hash with information on all the fans
my %fans = ();
foreach my $k (keys %$fan_table)
{
	my ($type,$id) = ((split(/\./, $k)) [-2,-1]);
	$fans{$id}{$type} = $$fan_table{$k};
}

# evaluating the fans
my $ok = 0;
my $nonok = 0;
foreach my $k (sort keys %fans)
{
	$returnsupp .= $fans{$k}{$FAN_DEV} . ": " . (($fans{$k}{$FAN_STATE} == 1) ? "OK" : "FAILED") . ($fans{$k}{$FAN_SPEED} ? " (" . $fans{$k}{$FAN_SPEED} . "RPM)" : "") . "; ";
	$ok++ if $fans{$k}{2} == 1;
	$nonok++ if $fans{$k}{2} != 1;
}

# generating the output
print "detected " . ($ok + $nonok) . " fans: " . $nonok . " are bad.";
print "|" . $returnsupp;
print "\n";

exit $ERRORS{"OK"} unless $nonok > 0;
exit $ERRORS{"CRITICAL"};

