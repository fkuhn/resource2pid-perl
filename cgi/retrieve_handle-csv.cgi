#!usr/bin/perl -w
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use List::Util 'first'; 
# *****************************************
# handles_csv.pl
# search for a handle in a csv file
# by passing a resource item query via cgi.
# *****************************************

# optain cgi query
# example query uri: 
$item_cgi = new CGI;
if ($item_cgi->param) {
	$item = $item_cgi->param(item);
}

$handle_filename = "dgdhandles.csv";
# open the csv file
open ($handles, $handle_filename) or die "Could not open file $!";

# read file content to an array
@handles = <$handles>;
close $handles;
	
# a test value to avoid cgi config
# $item = "PF--_E_00002";

# search the first occurence of the dgd id
$handle = first {/$item,/} @handles;
@ih = split(",", $handle);
$item_handle = $ih[1];

# return the handle uri
print "Content-Type: text/plain\n\n";
print $item_handle;
