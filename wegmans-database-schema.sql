-- CSC261 2016 Hwk 4
-- Created: Prof. Koomen, 2016-01-29

-- Database WEGMANS containing a fairly small set of Point-of-Sale (POS) data from summer 2013
-- For more info on the origins of this data, please contact Prof. Henry Kautz


--
-- Wegmans Stores
--

DROP TABLE IF EXISTS store CASCADE;

CREATE TABLE store (
	 store_num		SMALLINT PRIMARY KEY
	,store_name		CHAR(40) UNIQUE NOT NULL
	,store_zone		CHAR(25)
	,store_city		CHAR(18)
	,store_state		CHAR(2)
	,store_type		SMALLINT	-- 1 = Food Market, 2 = Food Market that sells wine, 3 = Dedicated Wine/Liquor store
);


--
-- Wegmans Merchandise (Items)
--

DROP TABLE IF EXISTS item CASCADE;

CREATE TABLE item (
	 item_number		INTEGER PRIMARY KEY
	,dept_categ_class	CHAR(6)		-- Department / Category / Class (1st two digits = Dept, middle two digits = Category, last two digits = Class)
	,item_des 		CHAR(30)	--  UNIQUE NOT NULL	-- Item Description
	,item_unt_qty		NUMERIC(9,3)	-- Item Size
	,size_unit_desc		CHAR(2)		-- Unit of Measure
	,brand_code		CHAR(4)		-- Brand Code
	,dept_num		SMALLINT	-- Two-digit Department Number
	,dept_name		VARCHAR(30)	-- Department Name
	,categ_num		SMALLINT	-- Two-digit Category Number
	,categ_name		VARCHAR(30)	-- Category Name
	,class_num		SMALLINT	-- Two-digit Class Number
	,class_name		VARCHAR(30)	-- Class Name
);


--
-- Wegmans Customers
--

DROP TABLE IF EXISTS customer CASCADE;

create table customer (
	 hshld_acct		INTEGER PRIMARY KEY	-- Household Number
	,birth_yr_head_hh	INTEGER		-- Birth year of the head of household
	,hh_income		INTEGER		-- Household annual income
	,hh_size		SMALLINT	-- Household size
	,adult_count		SMALLINT	-- Number of adults in household
	,child_count		SMALLINT	-- Number of children in household
	,birth_yr_oldest	INTEGER		-- Birth year of oldest child in household
	,birth_yr_youngest	INTEGER		-- Birth year of youngest child in household
	,bad_address		CHAR(1)		-- Y = Bad Address, N = Bad Address Flag not set
	,privacy		CHAR(1)		-- Y = Customer requested no communications, N = No Privacy request
	,application_date	DATE		-- Date that the customer's Shoppers Club application was approved
	,wine_email_sent	SMALLINT	-- Number of Wine Emails send to this customer in the last 52 weeks
	,wine_email_open	SMALLINT	-- Of the above emails sent, the number that were opened (note, a single email can be opened more than once
	,wine_email_click	SMALLINT	-- Of the above emails opened, the number that the user clicked on a link within the email message
);


--
-- Wegmans POS Transactions
--

DROP TABLE IF EXISTS postrans CASCADE;

create table postrans (
	 hshld_acct		INTEGER 	-- Household Number (this is the account number of the individual in the household that is currently designated as the primary account)
	,acct_num		INTEGER		-- Account Number
	,trans_num		INTEGER		-- Transaction Number
	,trans_date		DATE		-- Transaction Date
	,store_num		SMALLINT	-- Store Number
	,item_number		INTEGER		-- Wegmans Internal Item Number
	,dept_categ_class	CHAR(6)		-- Department / Category / Class (1st two digits = Dept, middle two digits = Category, last two digits = Class)
	,unit_count		SMALLINT	-- Units Sold
	,net_sales		NUMERIC(7,2)	-- Extended Scanned Price, minus electronic discounts and Wegmans coupons
	,gross_sales		NUMERIC(7,2)	-- Extended Scanned Price  
	,manuf_coupon		NUMERIC(7,2)	-- Face value of manufacturer coupon redeemed

	,PRIMARY KEY (trans_num,item_number)
	,FOREIGN KEY (hshld_acct) REFERENCES customer (hshld_acct) ON UPDATE CASCADE ON DELETE SET NULL
	,FOREIGN KEY (store_num) REFERENCES store (store_num) ON UPDATE CASCADE ON DELETE SET NULL
	,FOREIGN KEY (item_number) REFERENCES item (item_number) ON UPDATE CASCADE ON DELETE SET NULL
);
