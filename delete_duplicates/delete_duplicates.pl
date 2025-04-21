#!/opt/bcgov/bin/perl

use API::AKIPS;
use Text::CSV qw(csv);
use Getopt::Std;

my %options;
getopts("d", \%options);

my $akips = API::AKIPS->new();

my $dev_csv = $akips->nm_db('Command to pull inv');
my @dev_list = csv(in => \$dev_csv) or die "Couldn't parse AKIPS csv output";
@dev_list = @{$dev_list[0]};
undef $dev_csv;

my %unique;
my $duplicate_found = 0;

for my $dev (@dev_list) {
   my @temp = @{$dev};
   my $name = get_name($temp[0]);
   my ($full_name)   = ($temp[0] =~ /^([^ ]+ )/);
   my $uptime      = $temp[2];

   if ($name and $full_name and $uptime) {
      $unique{$name}{count}++;
      $unique{$name}{names}{$full_name} = $uptime;
      if ($unique{$name}{count} > 1) {
         $duplicate_found++;
      }
   }
}

$logger->logF("AKIPS Inv Scan completed $duplicate_found duplicates found");

my @to_be_deleted;
my $num_deleted      = 0;
my $interval_max     = 5;
my $interval_count   = 0;
my $cap              = 20;

for my $dev (keys %unique) {
   if ($cap < $interval_count){last;}
   if ($unique{$dev}{count} > 1) {
      print ("\tDuplicate Device Found : $dev -> ".$unique{$dev}{count}. " Records\n") if $options{'d'};
      my $i = 0;
      for $name (sort {$unique{$dev}{names}{$a} <=> $unique{$dev}{names}{$b}} keys %{$unique{$dev}{names}}) {
         if ($i == 0) {
            print ("\t\t".$i++.". ".$name ." added on ".localtime($unique{$dev}{names}{$name})." will be kept\n") if $options{'d'};
         }else{
            print ("\t\t".$i++.". $name added on ".localtime($unique{$dev}{names}{$name}). " will be deleted\n") if $options{'d'};
            $num_deleted++;
            $name =~ s/\s+//g;
            push(@to_be_deleted, $name);
         }
      }
      if ($num_deleted % $interval_max == 0 and $num_deleted > 0) {
         print ("Send Interval Reached: Interval $interval_count out of $cap completed - total devices removed $num_deleted\n") if $options{'d'};
         my $devices_csv = join(',', @to_be_deleted);
         $akips->site_script('delete_device','device_names', $devices_csv);
         @to_be_deleted = ();
         $interval_count++;
      }
   }
}


sub get_name {
   my $line = shift;
   my $name = ($line =~ /^([^- ]+)-? ?/)[0];
   if ($name){
      return $name;
   }
   return 0;
}
