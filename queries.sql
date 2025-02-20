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
		to_char(s.sale_date, 'FMday') as day_of_week,
		date_part('isodow', s.sale_date) as dow, 
		floor(sum(p.price * s.quantity)) as income
		from sales as s
		left join employees as e on s.sales_person_id = e.employee_id
		left join products as p on s.product_id = p.product_id
		group by seller, day_of_week, dow
		order by dow, seller) as tab;

--age groups
select
	case 
		when c.age between '16' and '25' then '16-25'
		when c.age between '26' and '40' then '26-40'
		else '40+'
	end as age_category,
	count(*) as age_count
from customers as c
group by age_category
order by age_category;

--customers by month
select
	to_char(s.sale_date, 'yyyy-mm') as selling_month,
	count(distinct s.customer_id) as total_customers,
	floor(sum(s.quantity * p.price)) as income
from sales as s
left join products as p
	on s.product_id = p.product_id
group by selling_month
order by selling_month;

--special offer
select 
	customer,
	sale_date,
	seller
from (
	select
		concat(c.first_name, ' ', c.last_name) as customer,	
		s.sale_date,
		concat(e.first_name, ' ', e.last_name) as seller,
		row_number() over (partition by s.customer_id order by s.sale_date asc) as rn
	from sales as s
	left join products as p
		on s.product_id = p.product_id
	left join employees as e
		on s.sales_person_id = e.employee_id
	left join customers as c
		on s.customer_id = c.customer_id
	where p.price = '0'
	order by s.customer_id ) as tab
where rn = 1;