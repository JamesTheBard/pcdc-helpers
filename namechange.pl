#!/usr/bin/perl

# Usage: fixFile.pl [filename] [team]
my $file = $ARGV[0];
my $team = $ARGV[1];
my $output = $ARGV[2];

# Handle it if the $output file isn't actually defined.
unless ($output) {
    $output = $file;
    print "Using the source file as the output file: $output\n";
}

# Verify that the $team number actually makes sense.
unless ($team =~ /^\d{1}$/) {
    die "Team number is not valid, select a team from 1 through 9.\n";
}

# Check if $file exists and die if it doesn't.
unless (-e $file) {
    die "$file doesn't exist, exiting\n";
}

# Open the original file and get all of the lines.
open(my $inputfh, "<", $file) or die "Cannot open config file: $!";
my @contents = (<$inputfh>);
close($inputfh);

# Open the original file again and basically run it over via the whole
# "not-append" write to file thing.
open(my $outputfh, ">", $output) or die "Cannot open config file: $!";

# Go through the file and change the team names looking for the "blue?"
# team name and setting it to the correct value (which is $team).
foreach my $line (@contents) {
    $x = $line;

    # This changes instances of "blue?" (blue1 -> blue3 if $team is 3)
    $x =~ s/blue[0-9]/blue${team}/g;

    # Uncomment this to get your IP change on. Remember to escape your decimal
    # places.
    # 10.0.10.17 -> 10.0.30.17 if $team is 3.
    # $x =~ s/10\.0\.\d{1,3}\.(\d{1,3})/10.0.${team}0.$1/g;

    print $outputfh $x;
}

# Close the file, and take a breath of accomplishment.
close($outputfh);
