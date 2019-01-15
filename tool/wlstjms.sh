#!/bin/sh

usage() {
    echo "Usage: $0 create queue"
    echo "       $0 delete queue"
}

crtQue()
{
cat > $tmppy 2> /dev/null <<!
def crt_queue(que_name):
    try:
        connect(adm_user, adm_passwd, url)
        edit()
        startEdit()

        target = getMBean('/Servers/' + tar_name)
        print target
        jms_res = getMBean('/JMSSystemResources/' + res_name)
        print jms_res
        if jms_res is None:
            jms_serv = create(serv_name, 'JMSServer')
            print jms_serv
            jms_serv.addTarget(target)
            jms_res = create(res_name, 'JMSSystemResource')
            jms_res.addTarget(target)

        sub_dep = getMBean('/JMSSystemResources/' + res_name + '/SubDeployments/' + dep_name)
        print sub_dep
        if sub_dep is None:
            sub_dep = jms_res.createSubDeployment(dep_name)
            sub_dep.addTarget(jms_serv)

        the_res = jms_res.getJMSResource()
        print "Creating  " + que_name + " ..."
        queue = the_res.createQueue(que_name)
        queue.setJNDIName('jms/' + que_name)
        queue.setSubDeploymentName(dep_name)

        save()
        activate(block="true")
        disconnect()
    except Exception, e:
        e.printStackTrace()
        dumpStack()
        raise("Error add queue for WLST")


adm_user = '$adminUser'
adm_passwd = '$adminPasswd'
url = '$url'
tar_name = '$target'
serv_name = '$jmsServ'
res_name = '$jmsRes'
dep_name = '$subDeploy'

crt_queue('$queue')

exit()
!
}

dltQue()
{
cat > $tmppy 2> /dev/null <<!
def dlt_que():

    try:
        connect(adm_user, adm_passwd, url)
        edit()
        startEdit()

        jms_res = delete(res_name, 'JMSSystemResource') 
        jms_serv = delete(serv_name, 'JMSServer') 

        save()
        activate(block="true")
        disconnect()
    except Exception, e:
        e.printStackTrace()
        dumpStack()
        raise("Error delete queue for WLST")


adm_user = '$adminUser'
adm_passwd = '$adminPasswd'
url = '$url'
serv_name = '$jmsServ'
res_name = '$jmsRes'

dlt_que()

exit()
!
}


case $# in
    2)
        queue=$2
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
adminUser="weblogic"
adminPasswd="weblogic1"
target="myserver"
jmsServ="jms_serv"
jmsRes="jms_res"
subDeploy="sub_deploy"

if [ x$cmd = "xcreate" ]
then
    crtQue
    java -cp $wlsjar $wlst $tmppy
    exit 0
fi

if [ x$cmd = "xdelete" ]
then
    dltQue
    java -cp $wlsjar $wlst $tmppy
    exit 0
fi

usage
exit 1
