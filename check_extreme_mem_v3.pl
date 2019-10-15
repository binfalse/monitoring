#!/usr/bin/perl -w
#################################################
#
#     Monitor MEMORY of an extreme networks device
#     written by Martin Scharm
#       see http://binfalse.de
#     modified for SNMPv3 by Benjamin Gauß
#
#################################################

use strict;
use Net::SNMP;
use Getopt::Long;
use Number::Format qw(format_bytes);

use lib "/usr/lib64/nagios/plugins/";
use utils qw($TIMEOUT %ERRORS);


my $MEM_TOTAL = '1.3.6.1.4.1.1916.1.32.2.2.1.2.1';
my $MEM_FREE  = '1.3.6.1.4.1.1916.1.32.2.2.1.3.1';
my $MEM_SYS  = '1.3.6.1.4.1.1916.1.32.2.2.1.4.1';
my $MEM_USER  = '1.3.6.1.4.1.1916.1.32.2.2.1.5.1';

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
my $warning = undef;
my $critical = undef;

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
	'c:s' => \$critical,
	'critical:s' => \$critical,
	'w:s' => \$warning,
	'warn:s' => \$warning,
	'T:s' => \$TIMEOUT,
	'timeout:s' => \$TIMEOUT
);

sub nonum
{
  my $num = shift;
  if ( $num =~ /^(\d+\.?\d*)|(^\.\d+)$/ ) { return 0 ;}
  return 1;
}
sub print_usage
{
    print "Usage: $0 -s <SWITCH> -U <USER> -A <AUTH-PASSWORD> -a <AUTH-PROTOCOL> -P <PRIV-PASSWORD> -p <PRIV-PROTOCOL> -w <WARNLEVEL> -c <CRITLEVEL> [-T <TIMEOUT>]\n\n";
    print "       <SWITCH>            the switch's hostname or ip address\n";
    print "       <USER>              the SNMPv3 username\n";
    print "       <AUTH-PASSWORD>     the password for SNMPv3 authentication\n";
    print "       <AUTH-PROTOCOL>     the protocol for SNMPv3 authentication\n";
    print "       <PRIV-PASSWORD>     the privacy password for SNMPv3 data transport\n";
    print "       <PRIV-PROTOCOL>     the privacy protocol for SNMPv3data transport\n";
    print "       <WARNLEVEL>         the % of free mem that triggers a warning\n";
    print "       <CRITLEVEL>         the % of free mem that triggers a critical message\n";
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
if (!defined($warning) || !defined($critical))
{
	print "Need Warning- and Critical-Info!\n";
	print_usage();
	exit $ERRORS{"UNKNOWN"};
}
$warning =~ s/\%//g; 
$critical =~ s/\%//g;
if ( nonum($warning) || nonum($critical))
{
	print "Only numerical Values for crit/warn allowed !\n";
	print_usage();
	exit $ERRORS{"UNKNOWN"}
}
if ($warning < $critical) 
{
	print "warning >= critical ! \n";
	print_usage();
	exit $ERRORS{"UNKNOWN"}
}


my ($session, $error) = Net::SNMP->session( -hostname  => $switch, -version   => 3, -username  => $username, -authpassword => $authpassword, -authprotocol => $authprotocol, -privpassword => $privpassword, -privprotocol => $privprotocol, -timeout   => $TIMEOUT);

if (!defined($session)) {
   printf("ERROR opening session: %s.\n", $error);
   exit $ERRORS{"CRITICAL"};
}


# retrieving values

my $result = $session->get_request(-varbindlist => [$MEM_TOTAL,$MEM_FREE,$MEM_SYS,$MEM_USER] );
if (!defined($result))
{
   printf("ERROR: couldn't retrieve memory values : %s.\n", $session->error);
   $session->close;
   exit $ERRORS{"CRITICAL"};
}
my $mem_total = $result->{$MEM_TOTAL};
my $mem_free = $result->{$MEM_FREE};
my $mem_sys = $result->{$MEM_SYS};
my $mem_user = $result->{$MEM_USER};


# generating the output
$returnvalue = $ERRORS{"WARNING"} if ($mem_free / $mem_total < $warning / 100);
$returnvalue = $ERRORS{"CRITICAL"} if ($mem_free / $mem_total < $critical / 100);

printf "free memory: %.2f%%", 100 * $mem_free / $mem_total;
printf "|total: %s; free: %s (%.2f%%); system: %s (%.2f%%); user: %s (%.2f%%)",
	format_bytes ($mem_total),
	format_bytes ($mem_free),
	100 * $mem_free / $mem_total,
	format_bytes ($mem_sys),
	100 * $mem_sys / $mem_total,
	format_bytes ($mem_user),
	100 * $mem_user / $mem_total;
printf "\n";

exit $returnvalue;
