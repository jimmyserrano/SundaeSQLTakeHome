--1. Top 100 actors by # of films in desc order
with cte as(
SELECT actor_id, COUNT(*) as total_films
FROM film f
inner join film_actor fa
on f.film_id=fa.film_id
group by actor_id
)
select first_name, last_name, total_films
from cte c
inner join actor a
on c.actor_id=a.actor_id
order by total_films desc
limit 100



--2. Film grouped by category name except sports and games, and ordered by total films des
SELECT name, COUNT(distinct f.film_id) as total_films
from film f
inner join film_category fc
on f.film_id=fc.film_id
inner join category c
on fc.category_id=c.category_id
where name != 'Sports' and name !='Games'
group by name
order by COUNT(distinct f.film_id) desc

--3.For Store 1 plot total # of rentals, revenue, # of cust for last 12 weeks
  with recursive cte as (
	select max(rental_ts) as calendar_date from rental r
	inner join inventory i
 		on r.inventory_id=i.inventory_id
 	where store_id=1
	union all
	select date(calendar_date - interval '1 week') as calendar_date 
 	from cte 
	where date(calendar_date - interval '1 week') > '01-01-2020')

select date_part('week',cte.calendar_date) as week, count(distinct r.rental_id) as total_rentals, sum(coalesce(amount, 0)) as revenue, count(distinct r.customer_id) as total_individuals
from cte 
left join (select * from rental r inner join inventory i on r.inventory_id=i.inventory_id where store_id=1) as r
	on date_part('week',r.rental_ts)=date_part('week',cte.calendar_date)
left join payment p
	on p.rental_id=r.rental_id
group by date_part('week',cte.calendar_date)
order by date_part('week',cte.calendar_date) desc
limit 12



  


--4. Active customers that rented PG films at least twice in last 15 days of month for July & Aug --2020, excluding Dallas 

with cte as (
select distinct r.customer_id
from rental r
inner join inventory i
on r.inventory_id=i.inventory_id
inner join film f
on i.film_id=f.film_id
inner join customer c
on r.customer_id=c.customer_id
inner join address a
on c.address_id=a.address_id
inner join city c2
on a.city_id=c2.city_id
where rating='PG' and  city!='Dallas' and country_id=103 and activebool=TRUE
and rental_ts >= '07-15-2020'and rental_ts <'08-01-2020'
group by r.customer_id
having count(r.customer_id)>1),
cte2 as (
select distinct r.customer_id
from rental r
inner join inventory i
on r.inventory_id=i.inventory_id
inner join film f
on i.film_id=f.film_id
inner join customer c
on r.customer_id=c.customer_id
inner join address a
on c.address_id=a.address_id
inner join city c2
on a.city_id=c2.city_id
where rating='PG' and  city!='Dallas' and country_id=103 and activebool=TRUE
and rental_ts >= '08-15-2020'and rental_ts <'09-01-2020'
group by r.customer_id
having count(r.customer_id)>1) 

select count(cte.customer_id) as US_active_users
from  cte
inner join cte2
on cte.customer_id=cte2.customer_id


--5. For Aug 2020, plot rolling average rental rates for prior 7 days.

--This query interprets rental rate as volume of rentals since question references rentals concentrated on certain days
with recursive cte as (
	select date('08-01-2020') as calendar_date
	union all
	select date(calendar_date + interval '1 day') as calendar_date 
  from cte 
	where date(calendar_date + interval '1 day') <= '08-31-2020'
),
cte2 as (
select date_part('day',rental_ts) as day, count(*) as total
from rental
where date_part('month',rental_ts)=8 
and date_part('year', rental_ts)=2020
group by date_part('day',rental_ts) )

select date_part('day',calendar_date) as day,avg(coalesce(total,0)) OVER (ORDER BY date_part('day',calendar_date) ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as seven_day_avg 
from cte
left join cte2
on date_part('day',calendar_date)=day


--This query interprets rental rate as the rental_rate field in film table
with recursive cte as (
	select date('08-01-2020') as calendar_date
	union all
	select date(calendar_date + interval '1 day') as calendar_date 
  from cte 
	where date(calendar_date + interval '1 day') <= '08-31-2020'
),
cte2 as (
select date_part('day',rental_ts) as day, avg(rental_rate) as daily_avg
from rental r
inner join inventory i
	on r.inventory_id=r.inventory_id
inner join film f
on i.film_id=f.film_id
where date_part('month',rental_ts)=8 
and date_part('year', rental_ts)=2020
group by date_part('day',rental_ts) )

select date_part('day',calendar_date) as day,avg(coalesce(daily_avg,0)) OVER (ORDER BY date_part('day',calendar_date) ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as seven_day_avg 
from cte
left join cte2
on date_part('day',calendar_date)=day
