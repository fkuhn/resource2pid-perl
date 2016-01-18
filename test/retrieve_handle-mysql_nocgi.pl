#!/usr/bin/perl -w
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use DBI;
# *************************
# cgi script to retrieve matching pids for resource item urls
# *************************
# define credentials
$DB_NAME = "handles";
$DB_DSN = "DBI:mysql:$DB_NAME";
$DB_USER = "handleuser";
$DB_PASSWD = "handlepassword";

# connect to the db via credentials
$handle_db = DBI->connect($DB_DSN, $DB_USER, $DB_PASSWD) or die "Error connecting to database: $!";

print "Enter a item url to lookup: ";
$item = <STDIN>;
chomp $item;
exit 0 if ($item eq "");

# trim item string
$item =~ s/^\s+|\s+$//g;

#***********************************
# Retrieve handle pid of query item.
#***********************************
# prepare a query and use ? as placeholder for $item value

$handle_query= $handle_db->prepare(qq/SELECT pidurl FROM handles.handletable WHERE item = ? LIMIT 1/) or die "Couldn't prepare statement";
$handle_query->bind_param(1, $item);
# execute the query with item as argument
$item_handle = $handle_query->execute($item);

# disconnect from db


# return the handle uri
if ($item_handle != 1 ){
        print "Content-Type: text/plain\n\n";
        print "No corresponding handle found for item:\n";
        print $item;    
}
else {
        print "Content-Type: text/plain\n\n";
		while ($row = $handle_query->fetchrow_arrayref()) {
			print "@$row[0]";
		}
		$handle_query->finish;
		
}
$handle_db->disconnect;

