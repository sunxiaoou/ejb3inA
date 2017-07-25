#!/bin/sh

createBuild()
{
cat > $module/build.xml 2> /dev/null <<!
<project name="$ejbname" default="package" basedir=".">
    <description>
        Build, deploy and run the Session EJB example for GlassFish.
    </description>

    <property environment="env"/>
    <property name="J2EE_HOME" value="\${env.AS_INSTALL}"/>
    <property name="admin.host" value="$host"/>
    <property name="admin.port" value="$port"/>
    <property name="admin.user" value="$user"/>

    <property name="ejb.name" value="$ejbname"/>
    <property name="app.name" value="$module"/>
    <property name="src.dir" value="src"/>
    <property name="bld.dir" value="bld"/>
    <property name="etc.dir" value="etc"/>


    <target name="init">
        <mkdir dir="\${bld.dir}"/>
    </target>

    <target name="compile" depends="init">
        <javac srcdir="\${src.dir}" destdir="\${bld.dir}">
            <classpath>
                <pathelement path="\${J2EE_HOME}/lib/javaee.jar"/>
            </classpath>
        </javac>
    </target>

    <target name="package" depends="compile">
        <jar destfile="\${app.name}.jar">
            <!-- metainf dir=".">
                <include name="ejb-jar.xml"/>
                <include name="weblogic-ejb-jar.xml"/>
            </metainf -->
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
        <exec executable="\${J2EE_HOME}/bin/asadmin" failonerror="false">
            <arg line="--user \${admin.user}"/>
            <arg line="--host \${admin.host}"/>
            <arg line="--port \${admin.port}"/>
            <arg line="undeploy"/>
            <arg line="\${app.name}"/>
        </exec>
    </target>

    <target name="deploy" depends="init" unless="ee">
        <echo message="Deploying \${app.name}"/>
        <exec executable="\${J2EE_HOME}/bin/asadmin" failonerror="false">
            <arg line="--user \${admin.user}"/>
            <arg line="--host \${admin.host}"/>
            <arg line="--port \${admin.port}"/>
            <arg line="deploy"/>
            <arg line="\${app.name}.jar"/>
        </exec>
    </target>

    <target name="run" depends="init">
        <java classname="${package}.\${ejb.name}Client">
            <classpath>
                <pathelement path="\${app.name}.jar" />
                <pathelement path="\${J2EE_HOME}/lib/gf-client.jar" />
                <pathelement path="\${J2EE_HOME}/modules/glassfish-naming.jar" />
            </classpath>
        </java>
    </target>

</project>
!

}

createCode()
{
cat > $srcdir/$ejbname.java	2> /dev/null <<!
package ${package};

import javax.ejb.Remote;

@Remote
public interface $ejbname {
    public String welcome(String name);
}
!

cat > $srcdir/${ejbname}Bean.java 2> /dev/null <<!
package ${package};

import javax.ejb.Stateless;

@Stateless
public class ${ejbname}Bean implements $ejbname {

    public String welcome(String name) {
        return String.format("Welcome %s to $ejbname!", name);
    }
}
!

cat > $srcdir/${ejbname}Client.java 2> /dev/null <<!
package ${package};

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import java.util.Properties;
import java.util.Date;

//import javax.ejb.EJB;

public class ${ejbname}Client {
    // @EJB
    //    private static $ejbname ejb;

    private static Context getInitialContext() throws NamingException {
        Properties props = new Properties();
        props.setProperty(Context.INITIAL_CONTEXT_FACTORY,
            "com.sun.enterprise.naming.SerialInitContextFactory");
        props.setProperty("org.omg.CORBA.ORBInitialHost", "$host");
        props.setProperty("org.omg.CORBA.ORBInitialPort", "$initport");
        return new InitialContext(props);
    }

    public static void main(String[] args) throws Exception {
        Context ic = getInitialContext();
        // $ asadmin list-jndi-entries
        $ejbname ejb = ($ejbname)ic.lookup("$package.$ejbname");

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
port=4848
user=admin
initport=3700


module=$1
ejbname=$2
package=com.xo.$module

srcdir=$module/src/com/xo/$module
mkdir -p $srcdir

createBuild
createCode
