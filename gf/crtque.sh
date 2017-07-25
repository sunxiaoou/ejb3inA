#!/bin/sh

if [ $# -lt 1 ]
then
	echo "Usage: $0 queue	# for examples - jms/queue"
	exit 1
fi

queue=$1

asadmin --host localhost --port 4848 delete-jms-resource \
	$queue

asadmin --host localhost --port 4848 create-jms-resource \
	--restype javax.jms.Queue \
	--enabled=true \
	$queue
