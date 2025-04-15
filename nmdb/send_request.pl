# This is a legacy site script to be replace with web_adb_new when older scripts are updated
sub web_adb
{
	my $mget = cgi_param('mget');
    my $mcalc = cgi_param('mcalc');
    my $mlist = cgi_param('mlist');
    my $series = cgi_param('series');
    my $get = cgi_param('get');
    
    my $csv = "";
  	if ($mget){
   	 	for my $line (adb_result ("mget ".$mget)) {
   	   		my ($device, $interface, $attr, undef, $val) = split (" ", $line, 5);
   	   		next if !defined($val);
   	   		$csv .= $device.",".$interface.",".$attr.",".$val."\n";
   		}
   	}
    if ($mcalc){
   	 	for my $line (adb_result ("mcalc ".$mcalc)) {
   	   		my ($device, $interface, $attr, undef, $val) = split (" ", $line, 5);
   	   		next if !defined($val);
   	   		$csv .= $device.",".$interface.",".$attr.",".$val."\n";
   		}
   	}
    if ($mlist){
   	 	for my $line (adb_result ("mlist ".$mlist)) {
   	   		my ($device, $interface, $attr, undef, $val) = split (" ", $line, 5);
   	   		next if !defined($val);
   	   		$csv .= $device.",".$interface.",".$attr.",".$val."\n";
   		}
   	}
    if ($series){
      	for my $line (adb_result ("series ".$series)) {
            my ($device, $interface, $attr, undef, $val) = split (" ", $line, 5);
            next if !defined($val);
            $csv .= $device.",".$interface.",".$attr.",".$val."\n";
      	}
   	}
    if ($get){
		for my $line (adb_resut ("get ".$get)) {
			my $value = $line;
            next if !defined($value);
            $csv .= $value."\n";
        }
    }
   
   printf STDOUT ($csv);
   return;
}
