Firstly needs to customize admin properties in common.xml as:
    admin.host
    admin.port
    admin.user
    admin.password

Then, setup relevant resources:
    $ cd $DOMAIN_HOME/bin
    $ . ./setDomainEnv.sh   # set environment

    $ cd ~/student/ejb3inA/wl
    $ ij.sh                 # create derby database "sample"
    $ ant dltjdbc dltjms    # delete resources if necessary
    $ ant crtjdbc crtjms    # create resources
