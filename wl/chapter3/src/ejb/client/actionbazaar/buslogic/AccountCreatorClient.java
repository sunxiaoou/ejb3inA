package actionbazaar.buslogic;
import actionbazaar.persistence.*;
import javax.naming.Context;
import javax.naming.InitialContext;

import javax.ejb.EJB;

public class AccountCreatorClient {


    public static void main(String[] args) {

     try {
            Context context = new InitialContext();
            BidderAccountCreator accountCreator = (BidderAccountCreator)context.lookup("BidderAccountCreator#actionbazaar.buslogic.BidderAccountCreator");

        LoginInfo login = new LoginInfo();
        login.setUsername("dpanda");
        login.setPassword("welcome");

        accountCreator.addLoginInfo(login);

        BiographicalInfo bio = new BiographicalInfo();
        bio.setFirstName("Debu");
        bio.setLastName("Panda");

        accountCreator.addBiographicalInfo(bio);

        BillingInfo billing = new BillingInfo();
        billing.setCreditCardType("VISA");
        billing.setAccountNumber("0123456789");

        accountCreator.addBillingInfo(billing);

        // Create account
        accountCreator.createAccount();
    
     } catch (Exception ex) {
            ex.printStackTrace();
        }
}
}