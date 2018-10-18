#!/bin/sh

createBuild()
{
cat > $module/pom.xml 2> /dev/null <<!
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>$group</groupId>
    <artifactId>$module</artifactId>
    <packaging>ejb</packaging>
    <version>1.0-SNAPSHOT</version>
    <name>$module Maven Webapp</name>
    <url>http://maven.apache.org</url>
    <dependencies>
        <dependency>
            <groupId>javax</groupId>
            <artifactId>javaee-api</artifactId>
            <version>8.0</version>
            <scope>provided</scope>
        </dependency>
    </dependencies>
    <build>
        <finalName>$module</finalName>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-ejb-plugin</artifactId>
                <version>2.4</version>
                <configuration>
                    <ejbVersion>3.2</ejbVersion>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
!

}

createRun()
{
cat > $module/runclt.sh 2> /dev/null <<!
#!/bin/sh

# CLASSPATH=~/depot/src123100_build/Oracle_Home/wlserver/server/lib/weblogic.jar

java -classpath \$CLASSPATH:target/classes \\
    $group.$module.${ejbname}Client \\
    t3://$host:$port # $user $passwd

#    -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005 \\
!

chmod u+x $module/runclt.sh

}

createResource()
{
cat > $metadir/ejb-jar.xml 2> /dev/null <<!
<?xml version="1.0" encoding="UTF-8"?>
<ejb-jar version="3.0" xmlns="http://java.sun.com/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/ejb-jar_3_0.xsd">
    <display-name>${ejbname}Bean</display-name>
    <enterprise-beans>
        <session>
            <ejb-name>${ejbname}Bean</ejb-name>
            <ejb-class>$group.$module.${ejbname}Bean</ejb-class>
            <transaction-type>Container</transaction-type>
        </session>
    </enterprise-beans>
</ejb-jar>
!

cat > $metadir/weblogic-ejb-jar.xml 2> /dev/null <<!
<?xml version="1.0"?>
<weblogic-ejb-jar
        xmlns="http://www.bea.com/ns/weblogic/90"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.bea.com/ns/weblogic/90 http://www.bea.com/ns/weblogic/90/weblogic-ejb-jar.xsd">
    <weblogic-enterprise-bean>
        <ejb-name>${ejbname}Bean</ejb-name>
    </weblogic-enterprise-bean>
    <security-role-assignment>
        <role-name>$role</role-name>
        <principal-name>$user</principal-name>
    </security-role-assignment>
</weblogic-ejb-jar>
!

}

createCode()
{
cat > $srcdir/$ejbname.java 2> /dev/null <<!
package $group.$module;

import javax.ejb.Remote;

@Remote
public interface $ejbname {
    String welcome(String name);
}
!

cat > $srcdir/${ejbname}Bean.java 2> /dev/null <<!
package $group.$module;

import javax.annotation.security.RolesAllowed;
import javax.ejb.Stateless;
import javax.interceptor.Interceptors;

@Stateless(mappedName="$ejbname")

public class ${ejbname}Bean implements $ejbname {
    @RolesAllowed("$role")
    public String welcome(String name) {
        return String.format("Welcome %s to $ejbname!", name);
    }
}
!

cat > $srcdir/${ejbname}Client.java 2> /dev/null <<!
package $group.$module;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import java.util.Properties;
import java.util.Date;


public class ${ejbname}Client {
    private static String url = "t3://$host:$initport";
    private static String username = "$admusr";
    private static String password = "$admpwd";

    private static Context getInitialContext() throws NamingException {
        Properties props = new Properties();
        props.setProperty(Context.INITIAL_CONTEXT_FACTORY, "weblogic.jndi.WLInitialContextFactory");
        props.setProperty(Context.PROVIDER_URL, url);
        props.setProperty(Context.SECURITY_PRINCIPAL, username);
        props.setProperty(Context.SECURITY_CREDENTIALS, password);

        return new InitialContext(props);
    }

    public static void main(String[] argv) throws Exception {
        switch(argv.length) {
            case 3:
                password = argv[2];
            case 2:
                username = argv[1];
            case 1:
                url = argv[0];
                break;
        }

        Context ic = getInitialContext();
        $ejbname ejb = ($ejbname)ic.lookup("$ejbname#$group.$module.$ejbname");
        System.out.println((new Date()).toString() + " Invoking...");
        System.out.println(ejb.welcome("Curious George"));
        System.out.println((new Date()).toString() + " Invoked");
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
admusr=weblogic
admpwd=weblogic1
initport=7001

user=myuser
passwd=letmein0
role=myrole

module=$1
ejbname=$2
group=com.xo

srcdir=$module/src/main/java/com/xo/$module
metadir=$module/src/main/resources/META-INF
mkdir -p $srcdir $metadir

createBuild
createRun
createResource
createCode
