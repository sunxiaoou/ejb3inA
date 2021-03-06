#!/bin/sh

usage() {
	echo "Usage: $0 deploy appFile"
	echo "       $0 undeploy appName"
	echo "       $0 redeploy appFile"
	echo "       $0 startapp appName"
	echo "       $0 stopapp appName"
}

crtDeploy()
{
cat > $tmppy 2> /dev/null <<!
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

crtUndeploy()
{
cat > $tmppy 2> /dev/null <<!
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
        raise("Error Undeploy App for WLST AntTask tests")

undeploy_app()
exit()
!
}

crtRedeploy()
{
cat > $tmppy 2> /dev/null <<!
def deploy_app():
    try:
        connect('$user', '$passwd', '$url')
        redeploy('$app', appPath='$file', block='true')
        java.lang.Thread.sleep(1000)
        disconnect()
        # saveDomain()
    except Exception,e:
        e.printStackTrace()
        dumpStack()
        raise("Error Redeploy App for WLST AntTask tests")

deploy_app()
exit()
!
}

crtStartApp()
{
cat > $tmppy 2> /dev/null <<!
def start_app():
    try:
        connect('$user', '$passwd', '$url')
        startApplication('$app', block='true')
        java.lang.Thread.sleep(1000)
        disconnect()
        # saveDomain()
    except Exception,e:
        e.printStackTrace()
        dumpStack()
        raise("Error Start App for WLST AntTask tests")

start_app()
exit()
!
}

crtStopApp()
{
cat > $tmppy 2> /dev/null <<!
def stop_app():
    try:
        connect('$user', '$passwd', '$url')
        stopApplication('$app', block='true')
        java.lang.Thread.sleep(1000)
        disconnect()
        # saveDomain()
    except Exception,e:
        e.printStackTrace()
        dumpStack()
        raise("Error Stop App for WLST AntTask tests")

stop_app()
exit()
!
}


if [ $# -lt 2 ]
then
    usage
    exit 1
fi

tmppy=/tmp/wlst_$$.py
wlsjar=~/depot/src123100_build/Oracle_Home/wlserver/server/lib/weblogic.jar
wlst=weblogic.WLST

url="t3://localhost:7001"
user=weblogic
passwd=weblogic1
target=myserver

cmd=$1
file=$2
f=${file##*/}
app=${f%%.*}
ext=${f##*.}

if [ x$cmd = "xdeploy" ]
then
	if [ "$ext" = "jar" -o "$ext" = "war" -o "$ext" = "ear" -o -d "$file" ]
	then
		crtDeploy
		java -cp $wlsjar $wlst $tmppy
		exit 0
	fi
fi

if [ x$cmd = "xundeploy" -a "$app" = "$file" ]
then
    crtUndeploy
    java -cp $wlsjar $wlst $tmppy
    exit 0
fi

if [ x$cmd = "xredeploy" ]
then
	if [ "$ext" = "jar" -o "$ext" = "war" -o "$ext" = "ear" -o -d "$file" ]
	then
		crtRedeploy
		java -cp $wlsjar $wlst $tmppy
		exit 0
	fi
fi

if [ x$cmd = "xstartapp" -a "$app" = "$file" ]
then
    crtStartApp
    java -cp $wlsjar $wlst $tmppy
    exit 0
fi

if [ x$cmd = "xstopapp" -a "$app" = "$file" ]
then
    crtStopApp
    java -cp $wlsjar $wlst $tmppy
    exit 0
fi

usage
exit 1
