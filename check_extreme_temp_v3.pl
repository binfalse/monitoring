#!/usr/bin/perl -w
#################################################
#
#     Monitor TEMPERATURE of an extreme networks device
#     written by Martin Scharm
#       see http://binfalse.de
#     modified for SNMPv3 by Benjamin Gauß
#
#################################################

use strict;
use Net::SNMP;
use Getopt::Long;
use Scalar::Util qw(looks_like_number);

use lib "/usr/lib64/nagios/plugins/";
use utils qw($TIMEOUT %ERRORS);

my $TEMP_ALRM = '1.3.6.1.4.1.1916.1.1.1.7.0';
my $TEMP_CURR = '1.3.6.1.4.1.1916.1.1.1.8.0';


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
	print "Need Switch-Address!\n";
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


# retrieving values

my $result = $session->get_request(-varbindlist => [$TEMP_CURR, $TEMP_ALRM] );
if (!defined($result))
{
   printf("ERROR: couldn't retrieve temperature values : %s.\n", $session->error);
   $session->close;
   exit $ERRORS{"CRITICAL"};
}
my $temp_alarm = $result->{$TEMP_ALRM};
my $temp_current = $result->{$TEMP_CURR};



# generating the output
print "Temperature " . ($temp_alarm != 2 ? "ALARM" : "OK");
print "|" . (looks_like_number $temp_current ? "current temperature: ${temp_current}°C; " : "") . "alarm status of overtemperature sensor: $temp_alarm (1=alarm,2=ok)";
print "\n";

exit $ERRORS{"OK"} unless $temp_alarm != 2;
exit $ERRORS{"CRITICAL"};
