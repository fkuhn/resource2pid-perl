#!/usr/bin/perl -w

# *************************************************
# retrieves handles and updates a mysql db 
# intended to be run with a job scheduler, e.g. cron 
# *************************************************

use DBI;
use warnings "all";
use List::MoreUtils qw(each_array);
use String::Util qw(trim);
# define credentials
$DB_NAME = "handles";
$DB_DSN = "DBI:mysql:database=$DB_NAME";
$DB_USER = "handleuser";
$DB_PASSWD = "handlepassword";
$handle_db = DBI->connect($DB_DSN, $DB_USER, $DB_PASSWD);


# execute terminal command and capture STDOUT
$handles = qx{java -cp pid-cmdline-0.0.3.jar de.mannheim.ids.pid.cmdline.PidCommandLineClient -H handle.ids-mannheim.de -u repos -p wic4UJ3m list};


# split $handles into array
@handles_all = split /\n/, $handles;

# iterate over array, extract relevant infos and compose a new array
foreach $handle (@handles_all){

	# extract relevant infos 
	
	# split a raw handlestring into handle and resource id 
	my @handle_segments = split /;/, $handle;
	my $id = $handle_segments[2];
	# add a uri prefix
	my $url_prefix = "http://hdl.handle.net/";
	
	# push pid urls and items to separate arrays
	push @handles_url_processed, join "", $url_prefix, $handle_segments[1];
	push @handles_item_processed, $id;
	 
}
# **********************
# write array data to db
# **********************

# connect to db
$handle_db = DBI->connect($DB_DSN, $DB_USER, $DB_PASSWD) or die "Error connecting to database: $!";

# define a mysql query expression. REPLACE is used to avoid cloning of entries and
# to keep existing entries up to date. Works like INSERT for unseen entries.
my $sth_insert = $handle_db->prepare('REPLACE INTO handles.handletable SET item=?, pidurl=?') or die $dbh->errstr;

# define an iterator and iterate over values
my $handle_iterator = each_array(@handles_item_processed, @handles_url_processed);

while ( my ($val_item, $val_pidurl) = $handle_iterator->() ) {
  $sth_insert->execute($val_item, $val_pidurl) or die $dbh->errstr;
}

# close db
$handle_db->disconnect;


# old dgd regex section

# check for matching dgdid reference

	# regex for matching dgd items
	# [A-Z]{2,4}-{0,3}?(_[ES]_[0-9]{5})?(_SE_\d{2}_[AT]_\d{2})?(_DF_\d{2})

	# id=[A-Z]{2,4}-{0,3}?(_[ES]_[0-9]{5})?(_SE_\d{2}_[AT]_\d{2})?(_DF_\d{2})
	#if ($handle =~ /id=[A-Z]{2,4}-{0,3}?(_[ES]_[0-9]{5})?(_SE_\d{2}_[AT]_\d{2})?(_DF_\d{2})/ or
	#	$handle =~ /id=[A-Z]{2,4}-{0,3}/ or
	#	$handle =~ /id=[A-Z]{2,4}-{0,3}?(_[ES]_[0-9]{5})?(_SE_\d{2}_[AT]_\d{2})/)
	#{
