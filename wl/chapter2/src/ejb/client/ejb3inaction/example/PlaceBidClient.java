package ejb3inaction.example.buslogic;
import javax.naming.Context;
import javax.naming.InitialContext;
import ejb3inaction.example.persistence.Bid;

public class PlaceBidClient {
    public static void main(String [] args) {
        try {
            Context context = new InitialContext();
            PlaceBid placeBid = (PlaceBid)context.lookup("PlaceBid#ejb3inaction.example.buslogic.PlaceBid");
            Bid bid = new Bid();
             bid.setBidderId("npanda");
             bid.setItemId(Long.valueOf(100));
             bid.setBidPrice(20000.40);
              
            System.out.println("Bid Successful, BidId Received is:" +placeBid.addBid(bid));

        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

   }
