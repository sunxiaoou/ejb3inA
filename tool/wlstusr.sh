#!/bin/sh

usage() {
    echo "Usage: $0 create user passwd"
    echo "       $0 remove user"
}

crtUser()
{
cat > $tmppy 2> /dev/null <<!
def crt_user(user, passwd):
    try:
        connect('$adminUser', '$adminPasswd', '$url')
        realm = cmo.getSecurityConfiguration().getDefaultRealm()
        atnr = realm.lookupAuthenticationProvider('DefaultAuthenticator')
        if not atnr.userExists(user):
            print 'Create user: ' + user
            atnr.createUser(user, passwd, '')
        else:
            print 'User: ' + user +' already exists'
        disconnect()
        # saveDomain()
    except Exception, e:
        e.printStackTrace()
        dumpStack()
        raise("Error Add User for WLST")

crt_user('$user', '$passwd')
exit()
!
}

rmUser()
{
cat > $tmppy 2> /dev/null <<!
def rm_user(user):
    try:
        connect('$adminUser', '$adminPasswd', '$url')
        realm = cmo.getSecurityConfiguration().getDefaultRealm()
        atnr = realm.lookupAuthenticationProvider('DefaultAuthenticator')
        if not atnr.userExists(user):
            print 'User: ' + user +' does not exist'
        else:
            print 'Remove user: ' + user
            atnr.removeUser(user)
        disconnect()
        # saveDomain()
    except Exception, e:
        e.printStackTrace()
        dumpStack()
        raise("Error Add User for WLST")

rm_user('$user')
exit()
!
}


case $# in
    3)
        passwd=$3
        user=$2
        cmd=$1
        ;;
    2)
        user=$2
        cmd=$1
        ;;
    *)
        usage
        exit 1
		;;
esac

tmppy=/tmp/wlst_$$.py
wlsjar=~/depot/src123100_build/Oracle_Home/wlserver/server/lib/weblogic.jar
wlst=weblogic.WLST

url="t3://localhost:7001"
adminUser=weblogic
adminPasswd=weblogic1
target=myserver

if [ x$cmd = "xcreate" ]
then
    crtUser
    java -cp $wlsjar $wlst $tmppy
    exit 0
fi

if [ x$cmd = "xremove" ]
then
    rmUser
    java -cp $wlsjar $wlst $tmppy
    exit 0
fi

usage
exit 1
