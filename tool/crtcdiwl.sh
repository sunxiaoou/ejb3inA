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
    <packaging>war</packaging>
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
    </build>
</project>
!

}

createRun()
{
cat > $module/runclt.sh 2> /dev/null <<!
#!/bin/sh

xdg-open http://$host:$port/$module
!

chmod u+x $module/runclt.sh

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

cat > $webinf/web.xml 2> /dev/null <<!
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
package $group.$module;

import javax.enterprise.context.Dependent;

@Dependent
public class $bean {
    public String greet(String name) {
        return "Hello, " + name + ".";
    }
}
!

cat > $javadir/${bean}Managed.java 2> /dev/null <<!
package $group.$module;

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

creatExtension()
{
touch $webinf/beans.xml
cat > $webinf/classes/META-INF/services/javax.enterprise.inject.spi.Extension 2> /dev/null <<!
com.xo.$module.${bean}Extension
!

cat > $javadir/${bean}Extension.java 2> /dev/null <<!
package $group.$module;

import java.util.Set;

import javax.enterprise.event.Observes;
import javax.enterprise.inject.spi.AfterBeanDiscovery;
import javax.enterprise.inject.spi.AfterDeploymentValidation;
import javax.enterprise.inject.spi.Bean;
import javax.enterprise.inject.spi.BeanManager;
import javax.enterprise.inject.spi.BeforeBeanDiscovery;
import javax.enterprise.inject.spi.Extension;
import javax.enterprise.inject.spi.ProcessAnnotatedType;

public class ${bean}Extension implements Extension {

    void beforeBeanDiscovery(@Observes BeforeBeanDiscovery bbd) {
        System.out.println("Beginning the scanning process");
    }

    <T> void processAnnotatedType(@Observes ProcessAnnotatedType<T> pat) {
        System.out.println("scanning type: " + pat.getAnnotatedType().getJavaClass().getName());
    }

    void afterBeanDiscovery(@Observes AfterBeanDiscovery abd) {
        System.out.println("Finished the scanning process");
    }

    void afterDeploymentValidation(@Observes AfterDeploymentValidation adv, BeanManager bm) {
        Set<Bean<?>> beans = bm.getBeans($bean.class);
        if (beans == null || beans.isEmpty()) {
            throw new IllegalStateException("Could not find beans");
        }
        for (Bean<?> bean : beans) {
            System.out.println("validated bean: " + bean);
        }
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
group=com.xo

webdir=$module/src/main/webapp
webinf=$module/src/main/webapp/WEB-INF
javadir=$module/src/main/java/com/xo/$module
mkdir -p $webdir/resources/css
mkdir -p $webinf/classes/META-INF/services/
mkdir -p $javadir

createBuild
createRun
createWeb
createJava
# creatExtension
