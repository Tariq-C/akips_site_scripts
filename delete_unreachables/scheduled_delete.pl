# This scheduled site script is running every morning at 7:30 am to identify which values are either ready to be deleted
# and it will identify if there is a staged WAP that needs to be deleted
sub sched_0730_unreachable_device_alert
{
    my @states = ("SNMP.snmpState","PING.icmpState");
    my %down;
    my %stagedwaps;
   	
    for my $state (@states) {
		for my $line (adb_result ("mget * * * ".$state." value /down/")) {
      		my ($device, undef, $attr, undef, $val) = split (" ", $line);
            my (undef, undef, undef, $downdate) = split(",", $val);
            my $timedown = time() - $downdate;
            my $rawtimedown  = $timedown;
            my $dday = $timedown / (60*60*24);
            $dday = int($dday);
            $timedown -= $dday *60*60*24;
            my $dhour = $timedown / (60*60);
            $dhour = int($dhour);
            $timedown -= $dhour*60*60;
            my $dmin = $timedown / 60;
            $dmin = int($dmin);
      		next if !defined($val);
            if ($device =~ /^AP\d/) {
				$stagedwaps{$device} = " please remove from AKIPS";
			}
            next if !($device =~ /^([a-zA-Z]+\d+)/);
            next if $rawtimedown < 60*60*24*7;
            next if $device eq "mobra701";
            next if $device eq "mobra702";
            next if $device eq "surra255a";
            my $string = " has been down for ".$dday." days ".$dhour." hours ".$dmin." minutes";
                
            $down{$device} = $string;      
   		}
	}
    
    for my $key (keys %down){
    	my %return;
        $return{message} = "Unreachable Device : ".$key." ".$down{$key};
		  custom_add_to_alert_file(\%return);
	}
	
    for my $key (keys %stagedwaps) {
		my %return;
        $return{message} = "Staged WAP : ".$key." ".$stagedwaps{$key};
        custom_add_to_alert_file(\%return);
    }
    
   	return;
}
