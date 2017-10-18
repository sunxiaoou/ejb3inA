#!/bin/sh

createBuild()
{
cat > $module/build.xml 2> /dev/null <<!
<project name="$resname" default="package" basedir=".">
    <description>
        Build, deploy and run the JAX-RS example for Weblogic.
    </description>

    <property environment="env"/>
    <property name="WLS_HOME" value="\${env.WL_HOME}"/>

    <property name="admin.host" value="$host"/>
    <property name="admin.port" value="$port"/>
    <property name="admin.user" value="$user"/>
    <property name="admin.password" value="$password"/>

    <property name="res.name" value="$resname"/>
    <property name="app.name" value="$module"/>
    <property name="src.dir" value="src"/>
    <property name="bld.dir" value="bld"/>
    <property name="etc.dir" value="etc"/>

    <taskdef name="wldeploy" classname="weblogic.ant.taskdefs.management.WLDeploy"/>

    <target name="init">
        <mkdir dir="\${bld.dir}/WEB-INF/classes"/>
    </target>

    <target name="compile" depends="init">
        <javac srcdir="\${src.dir}" destdir="\${bld.dir}/WEB-INF/classes"/>
    </target>

    <target name="package" depends="compile">
        <war destfile="\${app.name}.war" duplicate="fail" needxmlfile="false">
            <fileset dir="\${bld.dir}">
                <exclude name="**/\${res.name}Client.class"/>
            </fileset>
        </war>
    </target>

    <target name="clean" depends="init">
        <delete>
            <fileset dir="." includes="\${app.name}.war,**/*.class" defaultexcludes="no"/>
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
            source="\${app.name}.war"
            failonerror="\${failondeploy}"/>
    </target>

    <target name="run" depends="init">
        <echo message="Executing client class"/>
        <java classname="$package.client.${resname}Client" fork="yes">
            <classpath>
                <pathelement location="\${bld.dir}/WEB-INF/classes"/>
                <!-- pathelement location="\${WLS_HOME}/server/lib/wlclient.jar"/-->
                <pathelement location="\${WLS_HOME}/server/lib/weblogic.jar"/>
            </classpath>
        </java>
    </target>

</project>
!

}

createCurl()
{
cat > $module/curl.sh 2> /dev/null <<!
#!/bin/sh

curl http://$host:$port/$module/resources/$resname
echo
!

chmod u+x $module/curl.sh

}

createCode()
{
cat > $srcdir/resource/$resname.java 2> /dev/null <<!
package $package.resource;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

@Path("$resname")
public class $resname {
    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String sayHello() {
        return "hello world!";
    }
}
!

cat > $srcdir/MyApplication.java 2> /dev/null <<!
package $package;

import java.util.HashSet;
import java.util.Set;
import javax.ws.rs.ApplicationPath;
import javax.ws.rs.core.Application;

import $package.resource.$resname;

@ApplicationPath("resources")
public class MyApplication extends Application {
    @Override
    public Set<Class<?>> getClasses() {
        final Set<Class<?>> classes = new HashSet<Class<?>>();
        classes.add($resname.class);
        return classes;
    }
}
!

cat > $srcdir/client/${resname}Client.java 2> /dev/null <<!
package $package.client;

import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.Invocation;
import javax.ws.rs.client.WebTarget;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

public class ${resname}Client {
    public static void main(String[] args) {
        Client client = ClientBuilder.newClient();
        WebTarget target = client.target("http://$host:$initport/$module");
        WebTarget resourceWebTarget;
        resourceWebTarget = target.path("resources/$resname");
        Invocation.Builder invocationBuilder;
        invocationBuilder = resourceWebTarget.request(MediaType.TEXT_PLAIN_TYPE);
        Response response = invocationBuilder.get();
        System.out.println(response.getStatus());
        System.out.println(response.readEntity(String.class));
    }
}
!

}



#### main ####

if [ $# -lt 2 ]
then
    echo "Usage: $0 moduleName resName"
    exit 1
fi

host=localhost
port=7001
user=weblogic
password=weblogic1
initport=7001

module=$1
resname=$2
package=com.xo.$module

srcdir=$module/src/com/xo/$module
mkdir -p $srcdir/resource
mkdir -p $srcdir/client

createBuild
createCurl
createCode
