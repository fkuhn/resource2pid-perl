#!/usr/bin/perl -w
use warnings "all";

# ************************************************
# handles2csv.pl
# retrieves handles and writes them to a csv file.
#
# note: to keep it simple, pid-cmdline-0.0.3.jar must be located
# in the same directory. Change if you like.
# ************************************************


# disabled ARGV handling and basic exception handling (didn't work, though)
# **********************
# if no cmd arg  (defining the handleinterface .jar) given
#if ($ARGV != 0) {
#	print "No path overwrite given. Assuming default location and command";
#	print "****";
	# capture STDOUT to $handles
#	$handles = qx{java -cp pid-cmdline-0.0.3.jar de.mannheim.ids.pid.cmdline.PidCommandLineClient -H handle.ids-mannheim.de -u repos -p wic4UJ3m list};
#}
#else {
	# if a command line arg was given use this and capture STDOUT
#	$handles = qx{$ARGV[0]};
#}
# ***********************

# option:
# for testing, load prefetched handles
# $handles = open(handlefile, '<', 'handles.txt') or die;

# return STDOUT of the command line call of PidCommandLineClient
$handles = qx{java -cp pid-cmdline-0.0.3.jar de.mannheim.ids.pid.cmdline.PidCommandLineClient -H handle.ids-mannheim.de -u repos -p wic4UJ3m list};

# split $handles into array
@handles_all = split /\n/, $handles;

# iterate over array, extract relevant infos and compose a new array
foreach $handle (@handles_all){

	# check for matching dgdid reference

	# complete regex for matching dgd items
	# [A-Z]{2,4}-{0,3}?(_[ES]_[0-9]{5})?(_SE_\d{2}_[AT]_\d{2})?(_DF_\d{2})

	# id=[A-Z]{2,4}-{0,3}?(_[ES]_[0-9]{5})?(_SE_\d{2}_[AT]_\d{2})?(_DF_\d{2})

	if ($handle =~ /id=[A-Z]{2,4}-{0,3}?(_[ES]_[0-9]{5})?(_SE_\d{2}_[AT]_\d{2})?(_DF_\d{2})/ or
		$handle =~ /id=[A-Z]{2,4}-{0,3}/ or
		$handle =~ /id=[A-Z]{2,4}-{0,3}?(_[ES]_[0-9]{5})?(_SE_\d{2}_[AT]_\d{2})/)
	{
		# extract relevant infos (cumbersome approach)
		my @dgd_handle = split /;/, $handle;
		my $dgd_id = $dgd_handle[2];
		my $url_prefix = "http://hdl.handle.net/";
		my @dgd_subid = split("&id=", $dgd_id);
		my $dgd_handle_url = join "", $url_prefix, $dgd_handle[1];

		# push the id, url pairs to @dgdhandles
		$dgd_handlestring = join(",", $dgd_subid[-1], $dgd_handle_url);
		push @dgd_handles, join("", $dgd_handlestring, "\n");

	}
}

#flush @dgd_handles to a csv file (hand-crafted approach)
open(CSVFILE, '>', 'dgdhandles.csv') or die "Could not open file 'dgdhandles.csv' $!";
print CSVFILE @dgd_handles;
close(CSVFILE);
