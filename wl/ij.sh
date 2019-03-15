#!/bin/sh

java \
	-cp "$DERBY_HOME/lib/derby.jar:$DERBY_HOME/lib/derbynet.jar:$DERBY_HOME/lib/derbytools.jar:$DERBY_HOME/lib/derbyoptionaltools.jar:$DERBY_HOME/lib/derbyclient.jar" \
	-Dij.driver=org.apache.derby.jdbc.ClientDriver \
	-Dij.protocol=jdbc:derby: -D"ij.database=//localhost:1527/sample;create=true" \
	-Dij.user=app -Dij.password=app \
	org.apache.derby.tools.ij
