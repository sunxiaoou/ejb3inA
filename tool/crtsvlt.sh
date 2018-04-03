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

xdg-open http://$host:$port/$module
!

chmod u+x $module/runclt.sh

}

createWeb()
{
cat > $webinf/web.xml 2> /dev/null <<!
<web-app version="3.1"
         xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd">
    <servlet>
        <servlet-name>$svltname</servlet-name>
        <servlet-class>com.xo.$module.$svltname</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>$svltname</servlet-name>
        <url-pattern>/</url-pattern>
    </servlet-mapping>
</web-app>
!

}

createJava()
{
cat > $javadir/$svltname.java 2> /dev/null <<!
package $group.$module;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;

public class $svltname extends HttpServlet {
    public void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {
        resp.setContentType("text/html");
        PrintWriter out = resp.getWriter();
        out.println("<html><head><title>hello world!</title></head>" +
                "<body>hello world!!</h1></body></html>");
    }
}
!

}



#### main ####

if [ $# -lt 2 ]
then
    echo "Usage: $0 moduleName svltName"
    exit 1
fi

host=localhost
port=7001
# user=weblogic
# password=weblogic1
initport=7001

module=$1
svltname=$2
group=com.xo

webdir=$module/src/main/webapp
webinf=$module/src/main/webapp/WEB-INF
javadir=$module/src/main/java/com/xo/$module
mkdir -p $webdir/resources/css
mkdir -p $webinf/classes/META-INF/services
mkdir -p $javadir

createBuild
createRun
createWeb
createJava
