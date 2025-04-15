
sub web_unreachable_count_alert
{
	my $unreachCount = 0;
    my @locations;
    my @states = ("SNMP.snmpState","PING.icmpState");
    my @groups = ("1-WAPS","1-NO-WAPS");
    my %unreachable;
    my %return;
    
    for my $state (@states) {
		for my $group (@groups) {
      		  for my $line (adb_result ("mget * * * ".$state." value /down/ all group ".$group)) {
      				my ($device, undef, $attr, undef, $val) = split (" ", $line);
                    my (undef, undef, undef, $downdate) = split(",", $val);
                	my $timedown = time() - $downdate;
                	my $rawtimedown  = $timedown;
                    if ($rawtimedown > 60*10 or $rawtimedown < 60*5){
						next;
                    }
                    my $location = ($device =~ /-([^-]+)$/)[0];
              		$unreachable{$location}{$device}++;
              }
        }
    }
    
    for my $loc (keys %unreachable) {
    	my $count = 0;
    	for my $dev (keys %{$unreachable{$loc}}) {
			$count++;
		}
        if ($count > 4) {
			$return{$loc} = $count;
		}
    }
    
    for my $location (keys %return){
    	my %r;
    	$r{message} = "Influx of Unreachable Devices at Location : ".$location." Count - ".$return{$location};
    	custom_add_to_alert_file(\%r);
	}
}
