/* Task A */
/* #(a)For all tuples, "birth_yr_oldest" and "birth_yr_youngest" of the household with children should not be zero.
Verification: count tuples for which this is not the case. Expected answer: 0.*/
select count(*) from customer where child_count > 0 AND birth_yr_oldest='0'AND birth_yr_youngest='0';
/* #(b)For all tuples, when net sales are larger than zero, the unit of the item sold should not be zero.
Verification: count tuples for which this is not the case. Expected answer: 0.*/
select count(*) from postrans where unit_count=0 AND net_sales<>0;
/* #(c)For all tuples, the birth year of the oldest child in a household should be earlier than that of the youngest child.
Verification: count tuples for which this is not the case. Expected answer: 0.*/
 select count(*) from customer where birth_yr_oldest> birth_yr_youngest;


/* Task B */
/* #11 What is the minimum, maximum and average net total spend per household?*/
select MIN(net_total_spend), MAX(net_total_spend), AVG(net_total_spend)
from (select hshld_acct,sum(net_sales) as net_total_spend from postrans group by hshld_acct) as per;

/* #12 How many households are there, and what is their average total spend, by the number of children in the household?*/
select child_count, count(distinct pos.hshld_acct) AS number_of_hshld, AVG(total_spend)AS average_total_spend
from  (select hshld_acct, SUM(net_sales) AS total_spend from postrans Group by hshld_acct) AS pos natural join customer
group by child_count
order by child_count;

/* #13 What is the average total spend per household with children, by age of the oldest child, sorted by age?*/
/* the age I caculate is at the end of the year of the most recent transaction in the sample*/
select (yr_most_recent_trans-birth_yr_oldest) AS age, AVG(total_spend)AS average_total_spend
from (select hshld_acct, SUM(net_sales) AS total_spend from postrans  group by hshld_acct) AS a natural join customer,
     (select extract(year from MAX(trans_date))AS yr_most_recent_trans from postrans) as year
where child_count > 0 AND birth_yr_oldest>0
group by age
order by age;


/* #14 What was the average age of all the children, by the end of the year of the most recent transaction in the sample? 
(Assumption: in households with more than two children the ages are evenly distributed between youngest and oldest.)*/
select SUM(child_count*(yr_most_recent_trans-(birth_yr_oldest+birth_yr_youngest)/2))/SUM(child_count) as average_age
from
    (select extract(year from MAX(trans_date))AS yr_most_recent_trans from postrans) as year, 
    (select child_count, birth_yr_oldest, birth_yr_youngest from customer 
    	where birth_yr_oldest>0 AND birth_yr_youngest>0) as child
where birth_yr_youngest< yr_most_recent_trans;

/* #15 What is the total sales (gross and net) over the sample period, by weekday? 
(Hint: you may find the PostgreSQL Date/Time Functions and Operators page helpful.)*/
select case when extract(dow from trans_date)=0 then 'Sunday'
            when extract(dow from trans_date)=1 then 'Monday'
            when extract(dow from trans_date)=2 then 'Tuesday'
            when extract(dow from trans_date)=3 then 'Wednesday'
            when extract(dow from trans_date)=4 then 'Thursday'
            when extract(dow from trans_date)=5 then 'Friday'
            when extract(dow from trans_date)=6 then 'Saturday'
            end AS weekdays,
            SUM(net_sales) AS total_net_sales, SUM(gross_sales)AS total_gross_sales
from postrans
group by weekdays;

/* #16 What is the total sales (gross and net) over the sample period, by weekday? 
List the results in order of weekday, Monday first, Sunday last.*/
select *
from(select case when extract(dow from trans_date)=0 then 'Sunday'
            when extract(dow from trans_date)=1 then 'Monday'
            when extract(dow from trans_date)=2 then 'Tuesday'
            when extract(dow from trans_date)=3 then 'Wednesday'
            when extract(dow from trans_date)=4 then 'Thursday'
            when extract(dow from trans_date)=5 then 'Friday'
            when extract(dow from trans_date)=6 then 'Saturday'
            end AS weekdays,
            SUM(net_sales) AS total_net_sales, SUM(gross_sales)AS total_gross_sales
from postrans
group by weekdays) AS w
order by  case weekdays
          when 'Monday' then 1
          when 'Tuesday' then 2
          when 'Wednesday' then 3
          when 'Thursday' then 4
          when 'Friday' then 5
          when 'Saturday' then 6
          when 'Sunday' then 7
          end;


/* #17 Which items in the CRAFT BEER category had a lowest net unit price that was less than the highest net unit price? 
For each of these items include in your results
the item number,
the item description,
the highest net unit price paid,
the lowest net unit price paid,
the discount percentage (how many percent was the lowest price less than the highest price), and
the number of transactions that sold that item for the lowest price.*/

select m.*, n.count
from
(select item_number,item_des, round(MAX(net_sales/unit_count),2)AS the_highest_net_unit_price_paid, round(MIN(net_sales/unit_count),2)AS the_lowest_net_unit_price_paid,
(MAX(net_sales/unit_count)-MIN(net_sales/unit_count))/MAX(net_sales/unit_count)AS discount_percentage from item natural join postrans
where categ_name='CRAFT BEER' AND unit_count<>0 
group by item_number, item_des
having MIN(net_sales/unit_count)<MAX(net_sales/unit_count))AS m natural join 
(select postrans2.item_number,count(trans_num) 
from (select item_number,min(net_sales/unit_count) from postrans where unit_count<>0 group by item_number) as postrans2 natural join postrans
where unit_count<>0 AND net_sales/unit_count=postrans2.min 
group by postrans2.item_number) AS n;

         

/* #18 How many households are there with a 3-year old as the youngest child, and how many of those buy diapers?*/
select hshld_with_youngest_child_3yr, how_many_buy_diapers_among_those 
from
(select count(hshld_acct) AS hshld_with_youngest_child_3yr from customer where 2014-birth_yr_youngest=3) AS a,
(select count(distinct customer.hshld_acct) AS how_many_buy_diapers_among_those 
	from item, postrans, customer
	where item.categ_name='DIAPERS' AND item.item_number= postrans.item_number AND postrans.hshld_acct=customer.hshld_acct AND 2014-birth_yr_youngest=3) AS b;

/* #19 How many POS transactions are there in the sample, how many included beer, how many included diapers, and how many included both? 
(Caveat: there are categories with BEER in the name that aren't beer!)*/
select total_trans_num, trans_include_beer, trans_include_diapers, trans_include_both
from (select count(distinct trans_num)AS total_trans_num from postrans)AS a,
(select count(distinct trans_num) AS trans_include_beer from postrans natural join item where categ_name like '%BEER%' AND categ_name<>'BEER MERCHANDISE') AS b,
(select count(distinct trans_num) AS trans_include_diapers from postrans natural join item where categ_name='DIAPERS') AS c,
(select count(distinct trans_num) AS trans_include_both
  from (select trans_num from postrans natural join item where categ_name like '%BEER%' AND categ_name<>'BEER MERCHANDISE'
intersect
select trans_num from postrans natural join item where categ_name='DIAPERS')AS d) AS e;



