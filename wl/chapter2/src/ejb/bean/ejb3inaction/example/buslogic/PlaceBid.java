package ejb3inaction.example.buslogic;

import javax.ejb.Remote;

import ejb3inaction.example.persistence.Bid;

@Remote
public interface PlaceBid {
    Long addBid(Bid bid);
}
