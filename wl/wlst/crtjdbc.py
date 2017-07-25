"""
This script configures a JDBC data source as a System Module and deploys it
to the server
"""
url='t3://' + sys.argv[1] + ':' + sys.argv[2]
username = sys.argv[3]
password = sys.argv[4]

connect(username,password,url)
edit()

# Change these names as necessary
dsname="ActionBazaarDS"
server=sys.argv[5]
cd("Servers/"+server)
target=cmo
cd("../..")

startEdit()
# start creation
print 'Creating JDBCSystemResource with name '+dsname
jdbcSR = create(dsname, "JDBCSystemResource")
theJDBCResource = jdbcSR.getJDBCResource()
theJDBCResource.setName("ActionBazaarDS")

connectionPoolParams = theJDBCResource.getJDBCConnectionPoolParams()
connectionPoolParams.setConnectionReserveTimeoutSeconds(25)
connectionPoolParams.setMaxCapacity(100)
# connectionPoolParams.setTestTableName("SYSTABLES")

dsParams = theJDBCResource.getJDBCDataSourceParams()
dsParams.addJNDIName("jdbc/ActionBazaarDS")

driverParams = theJDBCResource.getJDBCDriverParams()
driverParams.setUrl("jdbc:derby://localhost:1527/sample;create=true")
driverParams.setDriverName("org.apache.derby.jdbc.ClientXADataSource")

driverParams.setPassword("app")
# driverParams.setLoginDelaySeconds(60)
driverProperties = driverParams.getProperties()

proper = driverProperties.createProperty("user")
#proper.setName("user")
proper.setValue("app")

proper1 = driverProperties.createProperty("DatabaseName")
#proper1.setName("DatabaseName")
proper1.setValue("sample")

jdbcSR.addTarget(target)

save()
activate(block="true")

print 'Done configuring the data source'

