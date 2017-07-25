# This example script connects WLST to the Admin Examples Server
# * starts an edit session
# * removes a JMS system resource module.
import sys
from java.lang import System
    
print 'starting the script ....'

url='t3://' + sys.argv[1] + ':' + sys.argv[2]
username = sys.argv[3]
password = sys.argv[4]

connect(username,password,url)
edit()
startEdit()
jmsMySystemResource = delete("ABJMSResource", "JMSSystemResource") 
jmsMyServer1 = delete("ABJMSServer", "JMSServer") 
save()
activate(block="true")
print 'System Resource removed ...'
disconnect()
