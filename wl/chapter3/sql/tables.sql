drop table BIDDERS;
create table BIDDERS (
    username varchar(10) primary key,
    first_name varchar(30),
    credit_card_type varchar(20)
);

drop table BIDS;
create table BIDS (
    BID_ID BIGINT primary key,
    BID_DATE DATE,
    BID_STATUS VARCHAR(20),
    BID_PRICE FLOAT,
    BID_ITEM_ID BIGINT,
    BID_BIDDER VARCHAR(45)
);
