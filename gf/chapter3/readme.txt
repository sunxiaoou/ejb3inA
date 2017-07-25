
Build, deploy and running

    $ ant db-setup          # drop and create db tables, if need
    $ ant undeploy          # if need
    $ ant clean build
    $ ant deploy
    $ ant run               # run the stateless EJB
    $ ant run-sfsb          # run the stateful EJB


In server log, we can see a message - "Bidder successfully created .."

The result can be observed from ij tool:
    $ ij.sh
    ij> select * from BIDS;
    BID_ID |BID_DATE |BID_STATUS |BID_PRICE |BID_ITEM_ID |BID_BIDDER
    ------------------------------------------------------------------------
    1002   |NULL     |NULL       |10000.5   |100         |viper
    1 row selected

    ij> select * from BIDDERS;
    USERNAME |FIRST_NAME |CREDIT_CARD_TYPE
    ------------------------------------------------------------------------
    dpanda   |Debu       |VISA
    1 row selected
