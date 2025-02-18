--total ccustomers
select
	COUNT(c.customer_id) as customers_count
from customers as c;

--top 10 seller
select
	concat(e.first_name, ' ', e.last_name) as seller,
	count(*) as operations,
	floor(sum(p.price * s.quantity)) as income
from sales as s
left join employees as e
	on s.sales_person_id = e.employee_id
left join products as p
	on s.product_id = p.product_id
group by seller
order by income desc
limit 10;

--below avg income
select
	concat(e.first_name, ' ', e.last_name) as seller,
	floor(sum(p.price * s.quantity) / count(*)) as average_income
from sales as s
left join employees as e
	on s.sales_person_id = e.employee_id
left join products as p
	on s.product_id = p.product_id
group by seller
having floor(sum(p.price * s.quantity) / count(*)) < (
		select
		floor(sum(p.price * s.quantity) / count(*)) as total_average_income
		from sales as s
		left join products as p on s.product_id = p.product_id)
order by average_income asc;

--day to day sales
select
	seller,
	day_of_week,
	income
from (select
		concat(e.first_name, ' ', e.last_name) as seller,
		to_char(s.sale_date, 'FMDay') as day_of_week,
		date_part('isodow', s.sale_date) as dow, 
		floor(sum(p.price * s.quantity)) as income
		from sales as s
		left join employees as e on s.sales_person_id = e.employee_id
		left join products as p on s.product_id = p.product_id
		group by seller, day_of_week, dow
		order by dow, seller) as tab