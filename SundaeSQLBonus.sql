--The following analyses give insight into the customers, film categories, film ratings, stores that contribute the most to revenue. These should be prioritize and monitored to maintain ongoing business. 


--Here are the Top 10 film categories ordered by most revenue
select name, sum(amount)
from category
join film_category
on category.category_id = film_category.category_id
join film
on film_category.film_id = film.film_id
join inventory
on film.film_id = inventory.film_id
join rental
on inventory.inventory_id = rental.inventory_id
join payment
on rental.rental_id = payment.rental_id
group by name
order by 2 desc
limit 10;

--Here are the film ratings ordered by most revenue
select rating, sum(amount)
from category
join film_category
on category.category_id = film_category.category_id
join film
on film_category.film_id = film.film_id
join inventory
on film.film_id = inventory.film_id
join rental
on inventory.inventory_id = rental.inventory_id
join payment
on rental.rental_id = payment.rental_id
group by rating
order by 2 desc;

--Here is the rental volume by month and by store
--The late Spring and Summer months have larger volumes of rentals. Promotions should be emphasized and inventory should be supplemented.
SELECT rental_month, id_store, COUNT(*) AS rental_count
FROM (SELECT DATE_PART('month',r.rental_ts) AS rental_month,
             c.store_id AS id_store
     FROM rental r
     JOIN customer c
	 ON r.customer_id=c.customer_id) t1
GROUP BY 1,2
ORDER BY 1,2 DESC;

--Here are the top customers by total spent in 2020. These totals can be compared with the overall avg spent per customer in 2020: ~$163
WITH cte AS (
  	SELECT DATE_PART('year',p.payment_ts) AS year,
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    SUM(p.amount) as total
    FROM customer c
    INNER JOIN payment p
    ON c.customer_id = p.customer_id
    WHERE DATE_PART('year',p.payment_ts) = 2020
    GROUP BY 1,2
    ORDER BY 3 DESC
    LIMIT 50)
SELECT *
FROM cte;

--Here are the top customers by total # of rentals in 2020. These totals can be compared with the overall avg rentals per customer in 2020: 36
WITH cte AS (
  	SELECT DATE_PART('year',p.payment_ts) AS year,
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    COUNT(*) as total
    FROM customer c
    INNER JOIN payment p
    ON c.customer_id = p.customer_id
    WHERE DATE_PART('year',p.payment_ts) = 2020
    GROUP BY 1,2
    ORDER BY 3 DESC
    LIMIT 50)
SELECT *
FROM cte;
