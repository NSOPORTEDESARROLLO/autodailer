#!/usr/bin/perl

use strict;
use Asterisk::AGI;
use Asterisk::AMI;
use DBI;

my $AGI = new Asterisk::AGI;
my $caller_id = $AGI->get_variable('CALLERID(num)');
#my %input = $AGI->ReadParse();

$AGI->verbose("Llamada saliente de la exension: $caller_id\n");
$AGI->verbose("Revisando si la Extension pertenese a CallBack.....");



if (&check_if_callback($caller_id)) {

	$AGI->verbose("$caller_id es un usuario callback, revisando si se encuentra logueado\n");
} else {

	$AGI->verbose("$caller_id no es usuario callback, no hay restriccion de llamada\n");
	exit 0;
}


#Obtendo un refarray de las colas donde se encuentre la ext
my $queues = &get_callcenter_queues();


my $logged; 

#Checking if agents is on any queue (logged)
foreach (@{$queues}) {

	my $check=&check_agent_on_queue($_);

 	if ($check) {

 		$logged=1;	
 		last;

 	} else {

 		$logged=0;
 	}


 }

 #Debug value
 #print $logged;

if ($logged) {

 	$AGI->verbose("$caller_id logueado, permitirndo la llamada\n");
	exit 0;

 } else {

 	$AGI->verbose("$caller_id no se encuentra logueado al sistema, colgando llamada\n");
 	$AGI->exec("Playback","login-fail");
 	$AGI->hangup();

 }

##################################################################
#                                                                #
#                         SUBRUTINES.                            #
#																 #	
##################################################################



#Astman Manager Subrutines
sub check_agent_on_queue {

	#print "Checking queue $queue ...............";

	my $queue = $_[0];
	my $agent = $_[1];
	#my $agent = "SIP/1006";

	my $astman = Asterisk::AMI->new(PeerAddr => "localhost",
	                                PeerPort => "5038",
	                                Username => "admin",
	                                Secret => "055Admintmp123."
	                        );
	 
	die "Unable to connect to asterisk" unless ($astman);
	 
	my $action = $astman->send_action({ Action => 'Command',
	                         Command => "queue show $queue"
	                        });

	my $resp = $astman->get_response($action);
	
	#AMI LOGOFF
	$astman->send_action({ Action => 'logoff' });

	my $CMD=%{ $resp }{'CMD'};

	my @SP=grep(/dynamic/, @{$CMD}); #Filter data by dynamic key word
	
	my @check=grep(/$agent/, @SP); #Agent filter 
	my $return=grep(/$agent/, @SP);


	#Check if paused agent 
	if (grep(/paused/, @check)) {

		$return=0;

	}

	#Debug check value
	#print @check;
	

	#Desconecto de AMI
	sleep(1);  #Espero a que finalice AMI
	$astman->disconnect();
	

	return $return;

}
#### End AStman Subrutines



# MYSQL Subrutines
sub check_if_callback {

	my $user = $_[0];
	my $dsn = "DBI:mysql:database=call_center;host=172.17.0.1";
	my $username = "asterisk";
	my $password = "asterisk";

	# connect to MySQL database
	my %attr = ( PrintError=>0,  # turn off error reporting via warn()
	             RaiseError=>1   # report error via die()
	           );

	my $dbh = DBI->connect($dsn, $username, $password, \%attr) 
	    or die "Can't connect to database: $DBI::errstr";




	my $SQL = ("SELECT estatus FROM `agent` WHERE type='SIP' AND number=?"); 
	my @value = $dbh->selectrow_array($SQL,undef,$user);
	
	#print $value[0];

	my $return;
	if ( $value[0] eq "A" ) {
		$return = 1;
	}

	else {

		$return = 0;

	}

	#print $return;

	#Close database conexion
	$dbh->disconnect();

	return $return;


}



sub get_callcenter_queues {

	my $dsn = "DBI:mysql:database=call_center;host=172.17.0.1";
	my $username = "asterisk";
	my $password = "asterisk";

	# connect to MySQL database
	my %attr = ( PrintError=>0,  # turn off error reporting via warn()
	             RaiseError=>1   # report error via die()
	           );

	my $dbh = DBI->connect($dsn, $username, $password, \%attr) 
	    or die "Can't connect to database: $DBI::errstr";




	my $SQL = $dbh->prepare("SELECT queue FROM queue_call_entry"); 

	$SQL->execute();

	my @QUEUES;
	my @RETURN;

	while(@QUEUES = $SQL->fetchrow_array) {

		push @RETURN, $QUEUES[0];


	}

	#Queues Query finish 
	$SQL->finish();

	#Close database conexion
	$dbh->disconnect();

	return \@RETURN;

}
########## End Mysql Subrutines