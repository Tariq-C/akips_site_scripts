sub web_delete_unreachable_devices
{
   my $prune_days = 21;
   my $prune_time = 60 * 60 * 24 * $prune_days;
   my @arr = adb_result ("mget enum * ping4 PING.icmpState not group 1-TMC");
   my $cur_tt = time ();

   for my $line (@arr) {
      my ($dev, undef, undef, undef, $val) = split (" ", $line, 5);
      my (undef, $state, undef, $mtime, undef) = split (",", $val, 5);
      next if ($state ne "down");
      if ($cur_tt - $mtime > $prune_time) {
         printf " Removing %s\n", $dev;
         errlog ($ERR_DEBUG, "Deleting unreachable device %s", $dev);
         adb_send (sprintf ("delete device %s", $dev));
      }
   }
   adb_flush ();
}
