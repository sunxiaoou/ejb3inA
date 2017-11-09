#!/bin/sh

createBuild()
{
cat > $module/build.xml 2> /dev/null <<!
<project name="$bean" default="package" basedir=".">
    <description>
        Build, deploy and run a CDI example for Weblogic.
    </description>

    <property environment="env"/>
    <property name="WLS_HOME" value="\${env.WL_HOME}"/>

    <property name="admin.host" value="$host"/>
    <property name="admin.port" value="$port"/>
    <property name="admin.user" value="$user"/>
    <property name="admin.password" value="$password"/>

    <property name="bean.name" value="$bean"/>
    <property name="app.name" value="$module"/>
    <property name="src.dir" value="src"/>
    <property name="bld.dir" value="bld"/>

    <taskdef name="wldeploy" classname="weblogic.ant.taskdefs.management.WLDeploy"/>
    <taskdef name="openbrowser" classname="weblogic.ant.taskdefs.utils.OpenBrowser"/>

    <target name="init">
        <mkdir dir="\${bld.dir}/WEB-INF/classes"/>
    </target>

    <target name="compile" depends="init">
        <copy todir="\${bld.dir}" preservelastmodified="true" failonerror="false">
            <fileset dir="\${src.dir}/main/webapp"/>
        </copy>
        <javac srcdir="\${src.dir}" destdir="\${bld.dir}/WEB-INF/classes"/>
    </target>

    <target name="package" depends="compile">
        <war destfile="\${app.name}.war" duplicate="fail" needxmlfile="false">
            <fileset dir="\${bld.dir}" />
        </war>
    </target>

    <target name="clean" depends="init">
        <delete includeemptydirs="true">
            <fileset dir="." includes="\${app.name}.war,**/*.class" defaultexcludes="no"/>
            <fileset dir="\${bld.dir}" />
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
        <openbrowser failonerror="\${failonrun}"
            url="http://\${admin.host}:\${admin.port}/\${app.name}"/>
    </target>

</project>
!

}

createWeb()
{
mb=`echo ${bean}Managed | sed 's/^./\L&/'`
cat > $webdir/index.xhtml 2> /dev/null <<!
<?xml version='1.0' encoding='UTF-8' ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en"
      xmlns="http://www.w3.org/1999/xhtml"
      xmlns:ui="http://xmlns.jcp.org/jsf/facelets"
      xmlns:h="http://xmlns.jcp.org/jsf/html">
    <ui:composition template="/template.xhtml">
        <ui:define name="title">Simple Greeting</ui:define>
        <ui:define name="head">Simple Greeting</ui:define>
        <ui:define name="content">
            <h:form id="greetme">
               <p><h:outputLabel value="Enter your name: " for="name"/>
                  <h:inputText id="name" value="#{$mb.name}"/></p>
               <p><h:commandButton value="Say Hello" action="#{$mb.createSalutation}"/></p>
               <p><h:outputText value="#{$mb.salutation}"/> </p>
            </h:form>
        </ui:define>
    </ui:composition>
</html>
!

cat > $webdir/template.xhtml 2> /dev/null <<!
<?xml version='1.0' encoding='UTF-8' ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en"
      xmlns="http://www.w3.org/1999/xhtml"
      xmlns:h="http://xmlns.jcp.org/jsf/html"
      xmlns:ui="http://xmlns.jcp.org/jsf/facelets">
    <h:head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <h:outputStylesheet library="css" name="default.css"/>
        <title><ui:insert name="title">Default Title</ui:insert></title>
    </h:head>
    <body>
        <div id="container">
            <div id="header">
                <h2><ui:insert name="head">Head</ui:insert></h2>
            </div>
            <div id="space">
                <p></p>
            </div>
            <div id="content">
                <ui:insert name="content"/>
            </div>
        </div>
    </body>
</html>
!

cat > $webdir/resources/css/default.css 2> /dev/null <<!
body {
    background-color: #ffffff;
    font-size: 12px;
    font-family: Verdana, "Verdana CE",  Arial, "Arial CE", "Lucida Grande CE", lucida, "Helvetica CE", sans-serif;
    color: #000000;  
    margin: 10px;
}

h1 {
    font-family: Arial, "Arial CE", "Lucida Grande CE", lucida, "Helvetica CE", sans-serif;
    border-bottom: 1px solid #AFAFAF; 
    font-size:  16px;
    font-weight: bold;
    margin: 0px;
    padding: 0px;
    color: #D20005;
}

a:link, a:visited {
  color: #045491;
  font-weight : bold;
  text-decoration: none;
}

a:link:hover, a:visited:hover  {
  color: #045491;
  font-weight : bold;
  text-decoration : underline;
}
!

cat > $webdir/WEB-INF/web.xml 2> /dev/null <<!
<?xml version="1.0" encoding="UTF-8"?>
<web-app version="3.1" 
         xmlns="http://xmlns.jcp.org/xml/ns/javaee" 
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd">
    <servlet>
        <servlet-name>Faces Servlet</servlet-name>
        <servlet-class>javax.faces.webapp.FacesServlet</servlet-class>
        <load-on-startup>1</load-on-startup>
    </servlet>
    <servlet-mapping>
        <servlet-name>Faces Servlet</servlet-name>
        <url-pattern>*.xhtml</url-pattern>
    </servlet-mapping>
    <session-config>
        <session-timeout>
            30
        </session-timeout>
    </session-config>
    <welcome-file-list>
        <welcome-file>index.xhtml</welcome-file>
    </welcome-file-list>
</web-app>
!

}

createJava()
{
cat > $javadir/$bean.java 2> /dev/null <<!
package $package;

import javax.enterprise.context.Dependent;

@Dependent
public class $bean {
    public String greet(String name) {
        return "Hello, " + name + ".";
    }
}
!

cat > $javadir/${bean}Managed.java 2> /dev/null <<!
package $package;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.inject.Named;

@Named
@RequestScoped
public class ${bean}Managed {
    @Inject
    $bean obj;
    
    private String name;
    private String salutation;

    public void createSalutation() {
        this.salutation = obj.greet(name);
    }

    public String getSalutation() {
        return salutation;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }
}
!

}



#### main ####

if [ $# -lt 2 ]
then
    echo "Usage: $0 moduleName beanName"
    exit 1
fi

host=localhost
port=7001
user=weblogic
password=weblogic1
initport=7001

module=$1
bean=$2
package=com.xo.$module

webdir=$module/src/main/webapp
javadir=$module/src/main/java/com/xo/$module
mkdir -p $webdir/resources/css
mkdir -p $webdir/WEB-INF
mkdir -p $javadir

createBuild
createWeb
createJava
