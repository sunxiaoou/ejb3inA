#!/bin/sh

createBuild()
{
cat > $module/build.xml 2> /dev/null <<!
<project name="$ejbname" default="package" basedir=".">
    <description>
        Build, deploy and run the Session EJB example for Weblogic.
    </description>

    <property environment="env"/>
    <property name="WLS_HOME" value="\${env.WL_HOME}"/>

    <property name="admin.host" value="$host"/>
    <property name="admin.port" value="$port"/>
    <property name="admin.user" value="$user"/>
    <property name="admin.password" value="$password"/>

    <property name="ejb.name" value="$ejbname"/>
    <property name="app.name" value="$module"/>
    <property name="src.dir" value="src"/>
    <property name="bld.dir" value="bld"/>
    <property name="etc.dir" value="etc"/>

    <taskdef name="wldeploy" classname="weblogic.ant.taskdefs.management.WLDeploy"/>

    <target name="init">
        <mkdir dir="\${bld.dir}"/>
    </target>

    <target name="compile" depends="init">
        <javac srcdir="\${src.dir}" destdir="\${bld.dir}"/>
    </target>

    <target name="package" depends="compile">
        <jar destfile="\${app.name}.jar">
            <metainf dir="etc">
                <include name="persistence.xml"/>
            </metainf>
            <fileset dir="\${bld.dir}"/>
        </jar>
    </target>

    <target name="clean" depends="init">
        <delete>
            <fileset dir="." includes="\${app.name}.jar,**/*.class" defaultexcludes="no"/>
        </delete>
    </target>

    <target name="undeploy" depends="init" unless="ee">
        <echo message="Undeploying \${app.name}"/>
        <wldeploy
            user="\${admin.user}"
            password="\${admin.password}"
            adminurl="t3://\${admin.host}:\${admin.port}"
            debug="true"
            action="undeploy"
            name="\${app.name}"
            failonerror="\${failondeploy}"/>
    </target>

    <target name="deploy" depends="init" unless="ee">
        <echo message="Deploying \${app.name}"/>
        <wldeploy
            user="\${admin.user}"
            password="\${admin.password}"
            adminurl="t3://\${admin.host}:\${admin.port}"
            debug="true"
            action="deploy"
            name="\${app.name}"
            source="\${app.name}.jar"
            failonerror="\${failondeploy}"/>
    </target>

    <target name="run" depends="init">
        <echo message="Executing client class"/>
        <java classname="$package.${ejbname}Client" fork="yes">
            <classpath>
                <pathelement location="$module.jar"/>
                <!-- pathelement location="\${WLS_HOME}/server/lib/wlclient.jar"/-->
                <pathelement location="\${WLS_HOME}/server/lib/weblogic.jar"/>
            </classpath>
        </java>
    </target>

</project>
!

}

createDesc()
{
cat > $etcdir/persistence.xml 2> /dev/null <<!
<?xml version="1.0"?>
<persistence xmlns="http://java.sun.com/xml/ns/persistence"
             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xsi:schemaLocation="http://java.sun.com/xml/ns/persistence
    http://java.sun.com/xml/ns/persistence/persistence_1_0.xsd"
            version="1.0">
    <persistence-unit name="$module">
        <jta-data-source>jdbc/ActionBazaarDS</jta-data-source>
        <properties>
            <property name="eclipselink.ddl-generation" value="drop-and-create-tables"/>
        </properties>
    </persistence-unit>
</persistence>
!

}

createRun()
{
cat > $module/runclt.sh 2> /dev/null <<!
#!/bin/sh

java -classpath \$CLASSPATH:$module.jar \\
    $package.${ejbname}Client \\
    t3://$host:$port
!

chmod u+x $module/runclt.sh

}

createCode()
{
cat > $srcdir/$ejbname.java 2> /dev/null <<!
package $package;

import javax.ejb.Remote;

@Remote
public interface $ejbname {
    String welcome(String name);
    Bid addBid(Bid bid);
}
!

cat > $srcdir/${ejbname}Bean.java 2> /dev/null <<!
package $package;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

@Stateless(mappedName="$ejbname")
public class ${ejbname}Bean implements $ejbname {
    @PersistenceContext(unitName="$module")
    private EntityManager em;

    public String welcome(String name) {
        return String.format("Welcome %s to $ejbname!", name);
    }

    public Bid addBid(Bid bid) {
        System.out.println("Adding bid, bidder ID=" + bid.getBidderId()
                + ", item ID=" + bid.getItemId() + ", bid amount="
                + bid.getBidPrice() + ".");
        em.persist(bid);
        System.out.println("Your bid your item id: " + bid.getItemId() + " was successful");
        System.out.println("Your bid id is: " + bid.getBidId());
        return bid;
    }
}
!

cat > $srcdir/${ejbname}Client.java 2> /dev/null <<!
package $package;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import java.util.Properties;
import java.util.Date;

//import javax.ejb.EJB;

public class ${ejbname}Client {
    // @EJB
    //    private static $ejbname ejb;

    private static String url = "t3://$host:$initport";

    private static Context getInitialContext() throws NamingException {
        Properties props = new Properties();
        props.setProperty(Context.INITIAL_CONTEXT_FACTORY,
            "weblogic.jndi.WLInitialContextFactory");
        props.setProperty(Context.PROVIDER_URL, url);
        return new InitialContext(props);
    }

    public static void main(String[] args) throws Exception {
        if (args.length > 0)
            url = args[0];

        Context ic = getInitialContext();
        $ejbname ejb = ($ejbname)ic.lookup("$ejbname#$package.$ejbname");
        System.out.println((new Date()).toString() + " Invoking...");
        System.out.println(ejb.welcome("Coffee Babe"));
        System.out.println((new Date()).toString() + " Invoked");

        Bid bid = new Bid();
        bid.setBidderId("Coffee Babe");
        bid.setItemId(Long.valueOf(100));
        bid.setBidPrice(20000.40);

        System.out.println("Bid Successful, BidId Received is:" + ejb.addBid(bid).getBidId());
    }
}
!

cat > $srcdir/Bid.java 2> /dev/null <<!
package $package;

import java.io.Serializable;
import java.sql.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "BIDS")
public class Bid implements Serializable {
    private Date bidDate;

    private Long bidId;

    private Double bidPrice;

    private Long itemId;

    private String bidderId;


    public Bid() {
    }


    public Bid(String bidderId, Long itemId, Double bidPrice) {
        this.itemId = itemId;
        this.bidderId = bidderId;
        this.bidPrice = bidPrice;
    }


    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "BID_ID")
    public Long getBidId() {
        return bidId;
    }


    @Column(name = "BID_DATE")
    public Date getBidDate() {
        return bidDate;
    }


    public void setBidDate(Date bidDate) {
        this.bidDate = bidDate;
    }


    public void setBidId(Long bidId) {
        this.bidId = bidId;
    }


    @Column(name = "BID_PRICE")
    public Double getBidPrice() {
        return bidPrice;
    }


    public void setBidPrice(Double bidPrice) {
        this.bidPrice = bidPrice;
    }


    @Column(name = "BID_ITEM_ID")
    public Long getItemId() {
        return itemId;
    }


    public void setItemId(Long itemId) {
        this.itemId = itemId;
    }


    @Column(name = "BID_BIDDER")
    public String getBidderId() {
        return bidderId;
    }


    public void setBidderId(String bidderId) {
        this.bidderId = bidderId;
    }
}
!

}



#### main ####

if [ $# -lt 2 ]
then
    echo "Usage: $0 moduleName ejbName"
    exit 1
fi

host=localhost
port=7001
user=weblogic
password=weblogic1
initport=7001

module=$1
ejbname=$2
package=com.xo.$module

etcdir=$module/etc
srcdir=$module/src/com/xo/$module
mkdir -p $etcdir $srcdir

createBuild
createDesc
createRun
createCode
