
Build, deploy and running

    $ ant db-setup          # drop and create db tables, if need
    $ ant undeploy          # if need
    $ ant clean build
    $ ant deploy
    $ ant run


In server log, we can see a message - "Shipping Request processed.."

The result can be observed from ij tool:
    $ cd ..
    $ ij.sh
    ij> select * from SHIPPING_REQUESTS;
    ITEM_ID |SHIPPING_ADDRESS |SHIPPING_METHOD |INSURANCE_AMOUNT
    ----------------------------------------------------------------------------------------
    10101   |101 In Hell      |snailMail       |101.0
    1 row selected
