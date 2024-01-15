--Q1: Who is the senior most employee based on job title?
select top 1 * from employee
order by levels desc



--Q2: Which countries have the most Invoices?
select billing_country, count(*) as number_of_invoices
from invoice
group by billing_country
order by number_of_invoices desc




--Q3: What are top 3 values of total invoice?
select top 3 invoice_id,total
from invoice
order by total desc




--Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals
select top 1 billing_city,SUM(total) as spent
from invoice
group by billing_city
order by spent



--Question 5: Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money.
select top 1 c.customer_id,first_name,last_name,SUM(total) as spent
from invoice i 
join customer c 
on i.customer_id=c.customer_id
group by c.customer_id,first_name,last_name
order by spent desc


--Question 6. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A
select distinct email,c.customer_id,first_name,last_name,g.name as genre_name
from customer c 
join invoice i
on c.customer_id=i.customer_id
join invoice_line il
on i.invoice_id=il.invoice_id
join track t
on il.track_id=t.track_id
join genre g
on t.genre_id=g.genre_id
where c.customer_id in (select distinct c.customer_id 
						from customer c 
						join invoice i
						on c.customer_id=i.customer_id
						join invoice_line il
						on i.invoice_id=il.invoice_id
						join track t
						on il.track_id=t.track_id
						join genre g
						on t.genre_id=g.genre_id
						where g.name='Rock')
order by email ,genre_name desc;
--joined by seeing schema and subquery finds the customer_id which listens to rock music







--Question 7. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands
SELECT TOP 10 artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name ='Rock'
GROUP BY artist.artist_id,artist.name
ORDER BY number_of_songs DESC







--Question 8. Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first
with cte as (select *,avg(milliseconds) over () as avg_length
			from track)
select name,milliseconds
from cte 
where milliseconds>avg_length
order by milliseconds desc


--Question 9. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent
with cte as (select c.customer_id as customerid,first_name,last_name,ar.name as artist_name,il.invoice_id,avg(il.unit_price*il.quantity) as money_spent_on_each_sale
			from customer c 
			join invoice i
			on c.customer_id=i.customer_id
			join invoice_line il
			on i.invoice_id=il.invoice_id
			join track t
			on il.track_id=t.track_id
			join album a
			on t.album_id=a.album_id
			join artist ar
			on a.artist_id=ar.artist_id
			group by c.customer_id,ar.artist_id,il.invoice_id,first_name,last_name,ar.name
			)
select  customerid,first_name as customer_first_name,last_name as customer_last_name,artist_name,sum(money_spent_on_each_sale) as total_spent_on_each_customer
from cte 
group by customerid,first_name,last_name,artist_name



--Question 10. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres
with cte as (select  billing_country,genre_id as id,sum(il.quantity) as number_of_items_purchased,rank() over (partition by billing_country order by sum(il.quantity) desc) as rnk
			from invoice i
			join invoice_line il
			on i.invoice_id=il.invoice_id
			join track t
			on il.track_id=t.track_id
			group by  billing_country,genre_id
			)
select billing_country,name,number_of_items_purchased
from cte 
join genre
on cte.id=genre.genre_id
where rnk=1
order by billing_country,name




--Question 11. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount
with cte as (select first_name,last_name,billing_country,sum(total) as total_spending,rank() over(partition by billing_country order by SUM(total) desc) as rnk 
			from invoice
			join customer 
			on customer.customer_id = invoice.customer_id
			group by customer.customer_id,first_name,last_name,billing_country
			)
select first_name,last_name,billing_country,total_spending
from cte
where rnk=1
