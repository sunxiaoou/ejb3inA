"""
This script starts an edit session, creates two different JMS Servers, 
targets the jms servers to the server WLST is connected to and creates
jms topics, jms queues and jms templates in a JMS System module. The 
jms queues and topics are targeted using sub-deployments. 
"""

import sys
from java.lang import System


print "Starting the script ..."

url='t3://' + sys.argv[1] + ':' + sys.argv[2]
username = sys.argv[3]
password = sys.argv[4]
serverName = sys.argv[5]

connect(username,password,url)
edit()
startEdit()

servermb=getMBean("Servers/"+serverName)
if servermb is None:
    print 'Value is Null'

else:
    jmsserver1mb = create('ABJMSServer', 'JMSServer')
    jmsserver1mb.addTarget(servermb)

    jmsMySystemResource = create('ABJMSResource', 'JMSSystemResource')
    jmsMySystemResource.addTarget(servermb)
    
    subDep1mb = jmsMySystemResource.createSubDeployment('ABSubDeploy')
    subDep1mb.addTarget(jmsserver1mb)
    
    theJMSResource = jmsMySystemResource.getJMSResource()
    
    print "Creating OrderBillingQueue..."
    jmsqueue1 = theJMSResource.createQueue('OrderBillingQueue')
    jmsqueue1.setJNDIName('jms/OrderBillingQueue')
    jmsqueue1.setSubDeploymentName('ABSubDeploy')
    
    print "Creating ShippingRequestQueue..."
    jmsqueue2 = theJMSResource.createQueue('ShippingRequestQueue')
    jmsqueue2.setJNDIName('jms/ShippingRequestQueue')
    jmsqueue2.setSubDeploymentName('ABSubDeploy')
    
try:
    save()
    activate(block="true")
    print "script returns SUCCESS"   
except:
    print "Error while trying to save and/or activate!!!"
    dumpStack()
