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
    <properties>
        <maven.compiler.source>1.8</maven.compiler.source>
        <maven.compiler.target>1.8</maven.compiler.target>
    </properties>        
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

# xdg-open http://$host:$port/$module
curl http://$host:$port/$module
echo
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

cat > $webinf/beans.xml 2> /dev/null <<!
<?xml version="1.0" encoding="UTF-8"?>
<beans version="1.2" bean-discovery-mode="all"
       xmlns="http://xmlns.jcp.org/xml/ns/javaee"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/beans_1_2.xsd">
    <interceptors>
        <class>com.xo.$module.$intcpname</class>
    </interceptors>
</beans>
!

}

createJava()
{
cat > $javadir/Intcp.java 2> /dev/null <<!
package $group.$module;

import javax.interceptor.InterceptorBinding;
import java.lang.annotation.Documented;
import java.lang.annotation.Retention;
import java.lang.annotation.Target;

import static java.lang.annotation.ElementType.TYPE;
import static java.lang.annotation.RetentionPolicy.RUNTIME;

@Target({ TYPE })
@Retention(RUNTIME)
@Documented
@InterceptorBinding
public @interface Intcp {
}
!

cat > $javadir/$intcpname.java 2> /dev/null <<!
package $group.$module;

import javax.interceptor.AroundConstruct;
import javax.interceptor.AroundInvoke;
import javax.interceptor.Interceptor;
import javax.interceptor.InvocationContext;
import java.io.Serializable;

@Interceptor
@Intcp
public class $intcpname implements Serializable {
    @AroundInvoke
    public Object aroundInvoke(InvocationContext ic) throws Exception {
        System.out.println("*** invoke "+ ic.getMethod().getName() + " ***");
        return ic.proceed();
    }

    @AroundConstruct
    public void aroundConstruct(InvocationContext ic) throws Exception {
        System.out.println("*** Construct ***");
        ic.proceed();
    }
}
!

cat > $javadir/$mdbname.java 2> /dev/null <<!
package $group.$module;

import javax.ejb.ActivationConfigProperty;
import javax.ejb.MessageDriven;
import javax.interceptor.Interceptors;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageListener;
import javax.jms.TextMessage;

@MessageDriven(mappedName = "jms/$qname", activationConfig = {
        @ActivationConfigProperty(propertyName = "destinationType", propertyValue = "javax.jms.Queue")
})

@Intcp
public class $mdbname implements MessageListener {
    @Override
    public void onMessage(Message msg) {
        try {
            if (msg instanceof TextMessage) {
                TextMessage text = (TextMessage)msg;
                System.out.println("*** Message is: " + text.getText() + " ***");
            }
        } catch (JMSException e) {
            e.printStackTrace();
        }
    }
}
!

cat > $javadir/$prodrname.java 2> /dev/null <<!
package $group.$module;

import javax.jms.*;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;

public class $prodrname {
    private static String JMS_CONN_FACTORY = "weblogic.jms.XAConnectionFactory";    // For WLS
    // private static String JMS_CONN_FACTORY = "jms/__defaultConnectionFactory";   // For GF
    private static String JMS_QUEUE = "jms/$qname";

    private ConnectionFactory connectionFactory;
    private Queue queue;

    public $prodrname() {
        try {
            Context ctx = new InitialContext();
            connectionFactory = (ConnectionFactory)ctx.lookup(JMS_CONN_FACTORY);
            queue = (Queue)ctx.lookup(JMS_QUEUE);
        } catch (NamingException e) {
            throw new RuntimeException("Cannot lookup JMS resource", e);
        }
    }

    public void sendQueueMsg() {
        Connection connection = null;
        try {
            connection = connectionFactory.createConnection();
            Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
            MessageProducer messageProducer = session.createProducer(queue);
            TextMessage message = session.createTextMessage();
            message.setText(getClass().getName());
            messageProducer.send(message);
        } catch (JMSException e) {
            throw new RuntimeException("Cannot send message", e);
        } finally {
            if (connection != null) {
                try {
                    connection.close();
                } catch (JMSException e) {
                }
            }
        }
    }
}
!

cat > $javadir/$svltname.java 2> /dev/null <<!
package $group.$module;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;

public class $svltname extends HttpServlet {

    public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        $prodrname producer = new $prodrname();
        producer.sendQueueMsg();

        resp.setContentType("text/html");
        PrintWriter out = resp.getWriter();
        out.println("<html><head><title>$svltname</title></head><body>" + "hello world" + "</h1></body></html>");
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
intcpname=`echo $svltname | \
    sed -e 's/[^0-9]*\([0-9]\+\)/Intcp\1/' -e 's/[A-Z][a-z]*\([A-Z][a-z]*\)/Intcp\1/'`
mdbname=`echo $svltname | \
    sed -e 's/[^0-9]*\([0-9]\+\)/Mdb\1/' -e 's/[A-Z][a-z]*\([A-Z][a-z]*\)/Mdb\1/'`
prodrname=`echo $svltname | \
    sed -e 's/[^0-9]*\([0-9]\+\)/Prodr\1/' -e 's/[A-Z][a-z]*\([A-Z][a-z]*\)/Prodr\1/'`
qname=`echo $svltname | \
    sed -e 's/[^0-9]*\([0-9]\+\)/Q\1/' -e 's/[A-Z][a-z]*\([A-Z][a-z]*\)/Q\1/'`
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
