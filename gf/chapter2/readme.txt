
Build, deploy and running

    $ ant drop-que crt-que  # drop / create queue, if need
    $ ant undeploy          # if need
    $ ant clean build
    $ ant deploy
    $ ant run               # run the stateless EJB with JPA entity sample

In server log, we can see following messages:
	Adding bid, bidder ID=npanda, item ID=100, bid amount=20000.4
	Your bid your item id:100was successful
	Your bid id is: 1

The result can be observed from ij tool:
    $ ij.sh
    ij> select * from BIDS;
    BID_ID |BID_DATE |BID_STATUS |BID_PRICE |BID_BIDDER |BID_ITEM_ID
    ------------------------------------------------------------------------
    1      |NULL     |NULL       |20000.4   |npanda     |100
    1 row selected


    $ ant run-sfsb          # run the stateful EJB with MDB sample

In server log, we can see following messages:
	Billing Completed by MDB ..
	A/c No:123456789 charged..
