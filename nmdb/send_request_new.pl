# This is the new format of web_adb
sub web_adb_new
{
	my $call = cgi_param("call");
    my $type = (split(" ", $call))[0];
    my @allowed = ('mget','mlist','series','mcalc','get','list');
    my $pass = 0;
    for my $allowed (@allowed){
		if ($type eq $allowed) {
			$pass = 1;
        }
    }
    
   	if ($pass == 0) {
    	print STDOUT ($call ." is not an allowed command\n");
        return;
    }
    
    my $csv = "";
    for my $line (adb_result ($call)) {
		$csv .= join(",",split(" ",$line))."\n";
	}
    print STDOUT ($csv);
    return;
}
