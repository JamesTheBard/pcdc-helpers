#!/usr/bin/perl
# Usage: ifchange.pl [team] [adapter]
# Change the ol' eth configurations
use strict;
use File::Copy;

# Set some global values here.  They may say 'my', but they're really more like
# 'our' in their tiny variable hearts.
my $dir = "/etc/sysconfig/network-scripts";
#my $dir = "/home/jweatherly/Code/pcdc-zeppelin";
my $dns = "7";

# Make sure that the $team number is correct and makes sense.  It's the first
# argument of the script.
my $team = $ARGV[0];
unless ($team =~ /^\d{1}$/) {
    die "Team number is invalid, exiting.\n";
}

# Also make sure that the $adapter makes sense for CentOS/RHEL. This is nowhere
# near a proper regex for all possible adapter settings, but should suffice for
# the time being.  It's the second argument of the script.
my $adapter = $ARGV[1];
unless ($adapter =~ /^(eth[0-9]|em[0-9])$/) {
    die "Adapter is not recognized, exiting.\n";
}

# Let's grab all of the files in the ${dir}ectory and go through them.
opendir(DIR, $dir) or die "Could not open the appropriate directory.";
while (my $file = readdir(DIR)) {

    # Skip files that are either not files or don't match what we're looking
    # for.
    next unless (-f "$dir/$file");
    next unless ($file =~ /^ifcfg-${adapter}$/);

    # Ding, it's been found.  Make sure we back it up and toss in a .bak file.
    print "Found ethernet configuration file for '${adapter}'.\n";
    print "Backing up the file...";
    copy "$dir/$file", "$dir/$file.bak";
    print "done.\n";

    # Open the file, grab its contents, and start making changes in memory.
    # These are small files usually so it's not a big deal.
    open(my $fh, "<", "$dir/$file");
    my @contents = (<$fh>);
    open(my $outputfh, ">", "$dir/$file");

    # There be dragons here.
    foreach my $line (@contents) {
        # Make changes to a copy of the line.
        my $x = $line;

        # These are skip lines.  Basically these will 'remove' the matched
        # lines from the output file.
        next if ($x =~ /^DNS=/);

        # These are the lines that get changed.
        if ($x =~ /^IPADDR=/) {
            $x =~ s/10\.0\.\d{1,3}\.(\d{1,3})/10.0.${team}0.$1/g;
        }
        if ($x =~ /^GATEWAY=/) {
            $x =~ s/10\.0\.\d{1,3}\.1/10.0.${team}0.1/g;
        }
        if ($x =~ /^NETMASK/) {
            $x =~ "NETMASK=255.255.255.0\n";
        }
        if ($x =~ /^BOOTPROTO/) {
            $x =~ "BOOTPROTO=static\n";
        }

        # Write those changes to the new file.
        print $outputfh $x;
    }

    # These are specifically here because we deleted all instances of DNS
    # entries from the ifcfg file.
    my @additions = (
        "DNS1=10.0.${team}0.${dns}",
    );
    
    # Write the new entries to the bottom of the file.
    foreach my $i (@additions) {
        print $outputfh "$i\n";
    }

    # Close the file and find a beer for your work is done.
    close($outputfh);
}
