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
            <!-- metainf dir=".">
                <include name="ejb-jar.xml"/>
                <include name="weblogic-ejb-jar.xml"/>
            </metainf -->
            <fileset dir="\${bld.dir}">
                <exclude name="**/\${ejb.name}Client.class"/>
            </fileset>
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
        <java classname="$group.$module.${ejbname}Client" fork="yes">
            <classpath>
                <pathelement location="\${bld.dir}"/>
                <!-- pathelement location="\${WLS_HOME}/server/lib/wlclient.jar"/-->
                <pathelement location="\${WLS_HOME}/server/lib/weblogic.jar"/>
            </classpath>
        </java>
    </target>

</project>
!

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
    t3://$host:$port

#    -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005 \\
!

chmod u+x $module/runclt.sh

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

cat > $srcdir/${ejbname}Interceptor.java 2> /dev/null <<!
package $group.$module;

import javax.interceptor.AroundInvoke;
import javax.interceptor.InvocationContext;

public class ${ejbname}Interceptor {
    @AroundInvoke
    public Object visitFence(InvocationContext ic) throws Exception {
        System.out.println("*** Entered "+ ic.getMethod().getName() + " ***");
        return ic.proceed();
    }
}
!

cat > $srcdir/${ejbname}Bean.java 2> /dev/null <<!
package $group.$module;

import javax.ejb.Stateless;
import javax.interceptor.Interceptors;

@Stateless(mappedName="$ejbname")
@Interceptors(${ejbname}Interceptor.class)

public class ${ejbname}Bean implements $ejbname {
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
user=weblogic
password=weblogic1
initport=7001

module=$1
ejbname=$2
group=com.xo

srcdir=$module/src/main/java/com/xo/$module
mkdir -p $srcdir

createBuild
createRun
createCode
