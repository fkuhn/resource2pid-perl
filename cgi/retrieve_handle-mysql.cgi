#!/usr/bin/perl -w
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use DBI;
# *************************
# cgi script to retrieve matching pids for resource item urls
# *************************
# define credentials
$DB_NAME = "handles";
$DB_HOST = "localhost";
$DB_DSN = "DBI:mysql:$DB_NAME";
$DB_USER = "handleuser";
$DB_PASSWD = "handlepassword";

# connect to the db via credentials
$handle_db = DBI->connect($DB_DSN, $DB_USER, $DB_PASSWD) or die "Error connecting to database: $!";

# define a cgi object
$cgi = new CGI;
if ($cgi->param) {
	$item = $cgi->param(item);
}
else {
	print "Content-Type: text/plain\n\n";
	print "No item parameter given. Aborting";
	exit;
}

# Optional: Prepare item url for database query (strip)


# trim item string
chomp $item;
# $item =~ s/^\s+|\s+$//g;

#***********************************
# Retrieve handle pid of query item.
#***********************************
# prepare a query and use ? as placeholder for $item value

$handle_query= $handle_db->prepare(qq/SELECT pidurl FROM handles.handletable WHERE item = ? LIMIT 1/) or die "Couldn't prepare statement";

$item_quoted = $handle_db->quote($item)

$handle_query->bind_param(1, $item_quoted);

# execute the query with item as argument
$handle_query->execute($item); 

# return the handle uri
print "Content-Type: text/plain\n\n";
while ($row = $handle_query->fetchrow_arrayref()) {
	
	print "@$row[0]";
}

# disconnect from db
$handle_query->finish;
$handle_db->disconnect;

