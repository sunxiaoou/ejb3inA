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
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-war-plugin</artifactId>
                <version>2.4</version>
                <configuration>
                    <failOnMissingWebXml>false</failOnMissingWebXml>
                </configuration>
            </plugin>
        </plugins>
    </build>
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

createJava()
{
cat > $javadir/resource/$resname.java 2> /dev/null <<!
package $group.$module.resource;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import javax.json.Json;
import javax.json.JsonBuilderFactory;
import javax.json.JsonObject;

@Path("$resname")
public class $resname {
  private static final JsonBuilderFactory bf = Json.createBuilderFactory(null);

  @GET
  /*
  @Produces(MediaType.TEXT_PLAIN)
  public String sayHello() {
    return "hello world!";
  }
  */

  @Produces(MediaType.APPLICATION_JSON)
  public JsonObject doGet() {
    return bf.createObjectBuilder()
        .add("firstName", "John")
        .add("lastName", "Smith")
        .add("age", 25)
        .add("address", bf.createObjectBuilder()
            .add("streetAddress", "21 2nd Street")
            .add("city", "New York")
            .add("state", "NY")
            .add("postalCode", "10021"))
        .add("phoneNumber", bf.createArrayBuilder()
            .add(bf.createObjectBuilder()
                .add("type", "home")
                .add("number", "212 555-1234"))
            .add(bf.createObjectBuilder()
                .add("type", "fax")
                .add("number", "646 555-4567")))
        .build();
  }
}
!

cat > $javadir/MyApplication.java 2> /dev/null <<!
package $group.$module;

import java.util.HashSet;
import java.util.Set;
import javax.ws.rs.ApplicationPath;
import javax.ws.rs.core.Application;

import $group.$module.resource.$resname;

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

cat > $javadir/client/${resname}Client.java 2> /dev/null <<!
package $group.$module.client;

import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.Invocation;
import javax.ws.rs.client.WebTarget;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import javax.json.JsonObject;

public class ${resname}Client {
    public static void main(String[] args) {
        Client client = ClientBuilder.newClient();
        WebTarget target = client.target("http://$host:$initport/$module");
        WebTarget resourceWebTarget;
        resourceWebTarget = target.path("resources/$resname");
        Invocation.Builder invocationBuilder;
        // invocationBuilder = resourceWebTarget.request(MediaType.TEXT_PLAIN);
        invocationBuilder = resourceWebTarget.request(MediaType.APPLICATION_JSON);
        Response response = invocationBuilder.get();
        System.out.println(response.getStatus());
        // System.out.println(response.readEntity(String.class));
        System.out.println(response.readEntity(JsonObject.class));
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
group=com.xo

javadir=$module/src/main/java/com/xo/$module
mkdir -p $javadir/resource
mkdir -p $javadir/client

createBuild
createCurl
createJava
