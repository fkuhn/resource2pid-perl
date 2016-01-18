# resource2pid version 1.0




## A script collection to retrieve handle.net PIDs for IDS repository resources.

## Date: Jan 16 2016

### Tested OS Environment:

#### os and software
ubuntu 15.10
perl v5.20.2
Apache/2.4.12 (Ubuntu)
mysql  Ver 14.14 Distrib 5.6.27

#### perl modules
DBI 1.634
CGI 4.25


### Files 

./resource2pid/
 README.md
 
 backups/
    dgdhandles_backup.csv
    handles_backup.txt
 
 cgi/
    retrieve_handle-csv.cgi
    retrieve_handle-mysql.cgi
 
 cron/
    handles2mysql.pl
    handles2csv.pl
 
 data/
    handles.csv
    handles-raw.txt
 
 tool/
    pid-cmdline-0.0.3.jar
    
### File Description

#### cgi -- cgi scripts for repository resource to handle pid mapping
 - retrieve_handle-csv.cgi: cgi query handling with handles stored in the csv file.
 - retrieve_handles-mysql.cgi: cgi script for query handling of handles with mysql.

#### cron -- scripts that need to be run periodically with cron
- handles2csv.pl: retrieve handles and write them to a csv file.
- handles2mysql.pl: retrieve handles and store them in a mysql db table.

#### data -- data used by the csv version of the scripts
 - handles.csv: a handle to resource item mapping as comma separated file.
 - handles_raw.txt: raw data of retrieved handles.
 
#### tool -- the command line tool for pid retrieval
 - pid-cmdline-0.0.3.jar: java jar of the command line tool needed to retrieve 
   handle pids. its called in both handles2csv.pl and handles2mysql.pl 

#### backups -- backups of the csv related data files
 - handles_backup.csv: backup of csv handle file
 - handles-raw_backup.txt: backup of txt handle file 


## retrieve_handle-csv.cgi

Pass the dgd id of a resource in the webbrowser:
http://hostname/cgi-bin/dgdhandles-csv.cgi?PF--_E_00001
This finds the 


## retrieve_handle-mysql.cgi

This is the mysql version of dgdhandles-csv. instead of retrieving the
correct handle.net pid of a dgd item from a csv file, the script consults
a mysql database holding the same stock of information.
The database is populated by calling the script _handles2mysql.pl_.
It is strongly recommended to use this version.


## Installation and usage


### Prerequisites and MySQL 

1. Copy the contents of folders cgi/ and handles.csv found in data/ to your 
cgi-bin directory (e.g. /usr/lib/cgi-bin). 

2. Make sure the cgi files are executable for others, e.g.:
		
		$chmod a+x retrieve_handle-mysql.cgi 

3. Define a mysql database and a handleuser and grant permissions and make
   sure the permissions take effect:
   You need to login to mysql as root (mysql -u root -p)
    
    mysql> CREATE DATABASE handles;
    Query OK, 1 row affected (0,00 sec)

    mysql> CREATE USER handleuser@localhost IDENTIFIED BY 'handlepassword';
    Query OK, 0 rows affected (0,04 sec)

    mysql> GRANT ALL ON handles.* TO handleuser@localhost;
    Query OK, 0 rows affected (0,03 sec)
    
    mysql> FLUSH PRIVILEGES;
    Query OK, 0 rows affected (0,00 sec)

    mysql> CREATE TABLE handles.handletable(
        item VARCHAR(200) DEFAULT NULL,
        pidurl VARCHAR(200) DEFAULT NULL);
    Query OK, 0 rows affected (0,35 sec)


	NOTE: This example user will only be accessible via localhost. You
	will have to change addresses accordingly if you need to access the
	user remotely.

4. 	Copy the contens of cron/ and tool/ to your preferred directory.
	The files pid-cmdline-0.0.3.jar and handles2mysql.pl must be located in the same directory
	Both files must be executable.

4. To initially populate the database and its table with values, call 
		
		$perl handles2mysql.pl

5. You can check if everything went well via logging in with 
		mysql -u handleuser -p
		
	and call:
	
		mysql> USE handles;
		Reading table information for completion of table and column names
		You can turn off this feature to get a quicker startup with -A

		Database changed
		
	and:
	
		mysql> SHOW TABLE STATUS;
		
	which should return something like:
	+-------------+--------+---------+------------+-------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+-------------+------------+-------------------+----------+----------------+---------+
	| Name        | Engine | Version | Row_format | Rows  | Avg_row_length | Data_length | Max_data_length | Index_length | Data_free | Auto_increment | Create_time         | Update_time | Check_time | Collation         | Checksum | Create_options | Comment |
	+-------------+--------+---------+------------+-------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+-------------+------------+-------------------+----------+----------------+---------+
	| handletable | InnoDB |      10 | Compact    | 35196 |            223 |     7880704 |               0 |            0 |   4194304 |           NULL | 2016-01-13 12:45:33 | NULL        | NULL       | latin1_swedish_ci |     NULL |                |         |
	+-------------+--------+---------+------------+-------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+-------------+------------+-------------------+----------+----------------+---------+
	1 row in set (0,01 sec)
	
		
	return to your terminal with "exit"

### Enable and test CGI
 
6.	If not done before, you will have to enable cgi (with perl)for your apache2 
	webserver.
	
7.	How to activate the apache2 webserver cgi and perl modules on ubuntu:
		$sudo a2enmod cgi
		$sudo a2enmod perl
	
8. 	Restart your Apache Webserver:

		$ sudo service apache2 restart

9. For this example installation, you should now be able to open a browser window
   and enter a query url, for example:
		
		http://localhost/cgi-bin/retrieve_handle-mysql.cgi?item=http://repos.ids-mannheim.de/fedora/objects/clarind-ids:mkhz.000066/datastreams/JPEG/content

	The value of the "item" cgi-parameter is the resource-uri of an item in the database.
	Submitting this query should simply return 
	
		http://hdl.handle.net/10932/00-017B-E105-ACD8-1101-B 

	which points to exactly the same resource via persistent identifier.


### Enable cron to schedule handle pid updates
	
10. To make the script handles2mysql.pl update all handle pids frequently
	you can define a cronjob. For example, if you want the script to be
	called once a week, define a schedule with:
	
		crontab -e 
	and choose your editor.
	edit the opened file by adding the job in the crontab format, e.g.:
		
		0 5 * * mon perl /path/to/script/handles2mysq.pl
	
	will execute the script every monday at 5am. 


## Known Issues
* URIs of AGD Resource are not found. MySQL query string issue.
