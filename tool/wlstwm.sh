#!/bin/sh

usage() {
echo "Usage: $0 workmgr target"
# echo "       $0 undeploy appName"
}

crtWM()
{
cat > $tmppy 2> /dev/null <<!
def crt_wm(workmgr, mintc, target):
    try:
        connect('$user', '$passwd', '$url')
        edit()
        startEdit()

        print "Creating WorkManager %s and target to server %s" % (workmgr, target)

        minTC = cmo.getSelfTuning().lookupMinThreadsConstraint(mintc)
        if minTC is None:
            minTC = cmo.getSelfTuning().createMinThreadsConstraint(mintc)
        minTC.addTarget(getMBean('/Servers/' + target))
        minTC.setCount(3)

        workManager = cmo.getSelfTuning().lookupWorkManager(workmgr)
        if workManager is None:
            workManager = cmo.getSelfTuning().createWorkManager(workmgr)
        workManager.addTarget(getMBean('/Servers/' + target))
        workManager.setMinThreadsConstraint(minTC)

        save()
        activate(block="true")
        disconnect()
    except Exception, e:
        e.printStackTrace()
        dumpStack()
        raise("Error Deploy App for WLST AntTask tests")

crt_wm('$workmgr', 'mintc', '$target')
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
# target=myserver

workmgr=$1
target=$2

crtWM
java -cp $wlsjar $wlst $tmppy
