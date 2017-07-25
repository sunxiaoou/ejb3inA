package ejb3inaction.example.buslogic;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

import ejb3inaction.example.persistence.Bid;

@Stateless(mappedName = "PlaceBid")
public class PlaceBidBean implements PlaceBid {
    @PersistenceContext(unitName = "actionBazaar")
    private EntityManager em;


    public PlaceBidBean() {
    }


    public Long addBid(Bid bid) {
        System.out.println("Adding bid, bidder ID=" + bid.getBidderId()
                + ", item ID=" + bid.getItemId() + ", bid amount="
                + bid.getBidPrice() + ".");
        return save(bid).getBidId();
    }


    private Bid save(Bid bid) {
        em.persist(bid);
        System.out.println("Your bid your item id:" + bid.getItemId()
                + "was successful");
        System.out.println("Your bid id is: " + bid.getBidId());
        return bid;
    }
}
