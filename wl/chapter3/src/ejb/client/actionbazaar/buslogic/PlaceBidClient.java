package actionbazaar.buslogic;

import javax.ejb.EJB;

import actionbazaar.persistence.Bid;
import actionbazaar.persistence.Bidder;
import actionbazaar.persistence.Item;
import javax.naming.Context;
import javax.naming.InitialContext;

public class PlaceBidClient {
    
    //private static BidManager placeBid;


    public static void main(String[] args) {
        
            
        try {
            Context context = new InitialContext();
            BidManager placeBid = (BidManager)context.lookup("BidManager#actionbazaar.buslogic.BidManager");
            Item item = new Item();
            item.setItemId(new Long(100));

            Bidder bidder = new Bidder();
            bidder.setUserId("viper");

            Bid bid = new Bid();
            bid.setBidder(bidder);
            bid.setItem(item);
            bid.setBidPrice(10000.50);
            System.out.println("Bid Successful, BidId Received is:"
                    + placeBid.addBid(bid));
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }
}
