#!/bin/sh

if [ $# -lt 1 ]
then
	echo "Usage: $0 cmd (start | stop)"
	exit 1
fi

target=$1

if [ $target = "start" ]
then
	asadmin start-domain --verbose --debug &
	asadmin start-database
else
	asadmin stop-database
	asadmin stop-domain domain1
fi

# asadmin list-jndi-entries
# asadmin start-database
