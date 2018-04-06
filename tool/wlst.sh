#!/bin/sh

crtUndeploy()
{
cat > $undeploy 2> /dev/null <<!
def undeploy_app():
    try:
        connect('$user', '$passwd', '$url')
        undeploy('$app', '$target', block='true', timeout=60000)
        java.lang.Thread.sleep(1000)
        disconnect()
        # saveDomain()
    except Exception,e:
        e.printStackTrace()
        dumpStack()
        raise("Error Deploy App for WLST AntTask tests")

undeploy_app()
exit()
!
}

crtDeploy()
{
cat > $deploy 2> /dev/null <<!
def deploy_app():
    try:
        connect('$user', '$passwd', '$url')
        deploy('$app', '$file', targets='$target', block='true')
        java.lang.Thread.sleep(1000)
        disconnect()
        # saveDomain()
    except Exception,e:
        e.printStackTrace()
        dumpStack()
        raise("Error Deploy App for WLST AntTask tests")

deploy_app()
exit()
!
}


if [ $# -lt 1 ]
then
	echo "Usage: $0 appfile | appname"
	exit 1
fi

undeploy=/tmp/undeploy.py
deploy=/tmp/deploy.py
wlsjar=~/depot/src123100_build/Oracle_Home/wlserver/server/lib/weblogic.jar
wlst=weblogic.WLST

url="t3://localhost:7001"
user=weblogic
passwd=weblogic1
target=myserver

file=$1
f=${file##*/}
app=${f%%.*}
ext=${f##*.}

if [ "$app" = "$file" ]
then
	crtUndeploy
	java -cp $wlsjar $wlst $undeploy
	exit 0
fi

if [ "$ext" != "jar" -a "$ext" != "war" -a "$ext" != "ear" ]
then
	echo "Usage: $0 appfile | appname"
	exit 1
fi

crtDeploy
java -cp $wlsjar $wlst $deploy
exit 0
