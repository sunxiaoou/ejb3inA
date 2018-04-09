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
        <java classname="$group.$module.\${ejb.name}Client" fork="yes">
            <classpath>
                <pathelement location="\${app.name}.jar"/>
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

java -classpath \$CLASSPATH:target/$module.jar \\
    $group.$module.${ejbname}Client \\
    t3://$host:$port
!

chmod u+x $module/runclt.sh

}

createCode()
{
cat > $srcdir/${ejbname}Bean.java 2> /dev/null <<!
package $group.$module;

import javax.ejb.MessageDriven;
import javax.ejb.MessageDrivenContext;
import javax.ejb.ActivationConfigProperty;
import javax.jms.MessageListener;
import javax.jms.Message;
import javax.jms.TextMessage;
import javax.jms.JMSException;
import javax.annotation.Resource;
import java.util.logging.Logger;


@MessageDriven(mappedName = "$queue", activationConfig = {
    @ActivationConfigProperty(propertyName = "destinationType", propertyValue = "javax.jms.Queue")
    }
)

public class ${ejbname}Bean implements MessageListener {
    static final Logger logger = Logger.getLogger("${ejbname}Bean");
    @Resource
    private MessageDrivenContext mdc;

    public void onMessage(Message inMessage) {
        TextMessage msg = null;

        try {
            if (inMessage instanceof TextMessage) {
                msg = (TextMessage) inMessage;
                logger.info("MESSAGE BEAN: Message received: " + msg.getText());
            } else {
                logger.warning("Message of wrong type: " + inMessage.getClass().getName());
            }
        } catch (JMSException e) {
            e.printStackTrace();
            mdc.setRollbackOnly();
        } catch (Throwable te) {
            te.printStackTrace();
        }
    }
}
!

cat > $srcdir/${ejbname}Client.java 2> /dev/null <<!
package $group.$module;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import java.util.Properties;
import javax.jms.ConnectionFactory;
import javax.jms.Queue;
import javax.jms.Connection;
import javax.jms.Session;
import javax.jms.MessageProducer;
import javax.jms.TextMessage;
import javax.jms.JMSException;


public class ${ejbname}Client {
    private static String url = "t3://$host:$initport";
    private static String JMS_CONN_FACTORY = "weblogic.jms.XAConnectionFactory";
    private static String JMS_QUEUE = "$queue";

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

        final int NUM_MSGS = 3;
        Connection connection = null;

        try {
            Context ctx = getInitialContext();
            ConnectionFactory factory = (ConnectionFactory)ctx.lookup(JMS_CONN_FACTORY);
            connection = factory.createConnection();
            Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
            Queue queue = (Queue)ctx.lookup(JMS_QUEUE);
            MessageProducer producer = session.createProducer(queue);
            TextMessage message = session.createTextMessage();

            for (int i = 0; i < NUM_MSGS; i ++) {
                message.setText("This is message " + (i + 1));
                System.out.println("Sending message: " + message.getText());
                producer.send(message);
            }

            System.out.println("To see server.log if the bean received the messages.");
        } finally {
            if (connection != null) {
                try {
                    connection.close();
                } catch (JMSException e) {}
            }
            System.exit(0);
        }
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
queue=jms/Queue
group=com.xo

srcdir=$module/src/main/java/com/xo/$module
mkdir -p $srcdir

createBuild
createRun
createCode
