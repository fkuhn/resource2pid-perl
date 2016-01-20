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
# commented out
$item =~ s/^\s+|\s+$//g;

# subsitution of reserved URL notation
# & will be replaced by %26 
$item =~ s/%26/\&/;
# ? will be replaced by %3F
$item =~ s/%3F/\?/;

print "Content-Type: text/plain\n\n";
print $item;

# NOTE:
# URI Strings will match if submitted in percentage notification acc. to  RFC 1630
# http://repos.ids-mannheim.de/cgi-bin/retrieve_handle-mysql.cgi?item=http://dgd.ids-mannheim.de/service/DGD2Web/ExternalAccessServlet%3Fcommand=displayData%26id=PF--_E_00002_SE_01_A_01_DF_01


#**********************************tex*
# Retrieve handle pid of query item.
#***********************************
# prepare a query and use ? as placeholder for $item value

$handle_query= $handle_db->prepare(qq/SELECT pidurl FROM handles.handletable WHERE item = ? LIMIT 1/) or die "Couldn't prepare statement";

# $item_quoted = $handle_db->quote($item);
# TODO: check if quoted item works correctly for AGD resources
$handle_query->bind_param(1, $item);

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
