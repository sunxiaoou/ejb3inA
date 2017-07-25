#!/bin/sh

java \
	-cp "$JAVA_HOME/db/lib/derby.jar:$JAVA_HOME/db/lib/derbynet.jar:$JAVA_HOME/db/lib/derbytools.jar:$JAVA_HOME/db/lib/derbyoptionaltools.jar:$JAVA_HOME/db/lib/derbyclient.jar" \
	-Dij.driver=org.apache.derby.jdbc.ClientDriver \
	-Dij.protocol=jdbc:derby: -D"ij.database=//localhost:1527/sun-appserv-samples;create=true" \
	-Dij.user=app -Dij.password=app \
	org.apache.derby.tools.ij
