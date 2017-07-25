package actionbazaar.buslogic;

import javax.annotation.Resource;
import javax.jms.Connection;
import javax.jms.ConnectionFactory;
import javax.jms.Destination;
import javax.jms.MessageProducer;
import javax.jms.ObjectMessage;
import javax.jms.Session;
import javax.naming.Context;
import javax.naming.InitialContext;

public class ShippingRequestJMSProducer {

    public static void main(String[] args) {
        long item = 10101;
        String address = "101 In Hell ";
        String method = "snailMail";
        double amount = 101.00;

        try {
            Context context = new InitialContext();

            ConnectionFactory connectionFactory = (ConnectionFactory) context.lookup("weblogic.jms.ConnectionFactory");        
            
            Connection connection = connectionFactory.createConnection();
            connection.start();

            Session session = connection.createSession(false,
                    Session.AUTO_ACKNOWLEDGE);
            Destination destination = (Destination) context.lookup("jms/ShippingRequestQueue");

            MessageProducer producer = session.createProducer(destination);

            ObjectMessage message = session.createObjectMessage();
            ShippingRequest shippingRequest = new ShippingRequest();
            shippingRequest.setItem(item);
            shippingRequest.setShippingAddress(address);
            shippingRequest.setShippingMethod(method);
            shippingRequest.setInsuranceAmount(amount);
            message.setObject(shippingRequest);
            producer.send(message);
            session.close();
            connection.close();
            System.out.println("Shipping Request Message Sent ..");

        } catch (Throwable ex) {
            ex.printStackTrace();
        }
    }
}
