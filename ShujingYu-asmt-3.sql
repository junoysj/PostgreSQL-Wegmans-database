/*1 What is the category of the item (whose description is) 'BUDWEISER CAN'?*/
select item_des,categ_num,categ_name  from item where item_des='BUDWEISER CAN';

/*2 How many fluid ounces are in the item 'HEINEKEN LAGER' and what is the category?*/
select item_des, item_unt_qty, categ_name, categ_num from item where item_des='HEINEKEN LAGER';

/*3 How many stores are there in the sample?*/
select count(*) from store;

/*4 How many departments are there in the sample?*/
select count(distinct dept_num) from item;

/*5 How many stores in the sample are in New York state?*/
select count(*) from store where store_state='NY';

/*6 How many stores are there in the POS transactions?*/
select count(distinct store_num) from postrans;

/*7 What is the range of POS transaction dates in the sample?*/
select min(trans_date),max(trans_date) from postrans;

/*8 How many transaction entries are there from the WEGMANS MARKETPLACE store?*/
select count(trans_num) from (store natural join postrans) where store_name='WEGMANS MARKETPLACE';

/*9 Which stores (number, name, city and state), sorted by city and state, are not in the POS transactions?*/
select store_num, store_name, store_city, store_state 
from (select store_num from store EXCEPT select store_num from postrans) AS s natural join store order by store_state, store_city;

/*10 How much did the combined sample households spend during the first 15 days of 2014 versus the last 15 days of 2013?*/
select the_first_15_days_of_2014,the_last_15_days_of_2013
from (select sum (net_sales)
     from postrans
     where (trans_date> '2013-12-31'AND trans_date< '2014-01-16' ))AS the_first_15_days_of_2014,
     (select sum (net_sales)
     from postrans
     where (trans_date< '2014-01-01'AND trans_date> '2013-12-16' )) AS the_last_15_days_of_2013;
