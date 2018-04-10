#!/bin/sh

usage() {
	echo "Usage: $0 start"
	echo "       $0 stop"
	echo "       $0 deploy appFile"
	echo "       $0 undeploy appName"
}


cmd=$1
app=$2

if [ $# -eq 1 -a x$cmd = "xstart" ]
then
	asadmin start-domain --verbose --debug &
	asadmin start-database
elif [ $# -eq 1 -a x$cmd = "xstop" ]
then
	asadmin stop-database
	asadmin stop-domain domain1
elif [ $# -eq 2 -a x$cmd = "xdeploy" ]
then
	asadmin --host localhost --port 4848 --user admin deploy $app
elif [ $# -eq 2 -a x$cmd = "xundeploy" ]
then
	asadmin --host localhost --port 4848 --user admin undeploy $app
else
	usage
	exit 1
fi

# asadmin list-jndi-entries
# asadmin start-database
