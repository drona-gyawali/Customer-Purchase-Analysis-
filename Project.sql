-- Senior most employee based on job titile
SELECT 
    CONCAT(first_name, ' ', last_name) AS Employee_Name,
    title AS `Job Role`,
    levels
FROM
    employee
ORDER BY levels DESC
LIMIT 5;

-- Which country have the more invoices
SELECT 
    billing_country AS Country,
    COUNT(invoice_id) AS `Total Invoices`
FROM
    invoice
GROUP BY Country
ORDER BY `Total Invoices` DESC;
 
 -- what are the top 3 values of total-invoices
 SELECT 
    invoice_id, ROUND((total), 2) AS Value
FROM
    invoice
ORDER BY Value DESC
LIMIT 3;

-- which city has best customers. write a query which has the highest sum of invoices. return city and invoice total

SELECT 
    i.billing_city AS city,round(sum(total),2) as Total_value,
    SUM(il.invoice_id) AS Total_invoices
FROM
    invoice AS i
        JOIN
    invoice_line AS il ON i.invoice_id = il.invoice_id
GROUP BY city
ORDER BY Total_invoices DESC;

-- TO 5 customer who spent the more money 

SELECT 
     i.customer_id as ID,concat(c.first_name, ' ', last_name) AS Customer_name,
    c.country AS Country,
    c.email AS Email,
    ROUND(SUM(i.total), 2) AS Total_spend
FROM
    customer AS c
        JOIN
    invoice AS i ON c.customer_id = i.customer_id
GROUP BY ID,Customer_name , Email , Country
ORDER BY Total_spend DESC
LIMIT 5;


-- Find out the customer details(i.e name,email) where customer like only rock genre and should be ordered by email alphabetically
SELECT DISTINCT
    (CONCAT(c.first_name, ' ', last_name)) AS Customer_Name,
    c.email AS Email
FROM
    customer AS c
        JOIN
    invoice AS i ON c.customer_id = i.customer_id
        JOIN
    invoice_line AS il ON i.invoice_id = il.invoice_id
WHERE
    track_id IN (SELECT 
            track_id
        FROM
            track AS t
                JOIN
            genre ON t.genre_id = genre.genre_id
        WHERE
            genre.name LIKE 'Rock')
ORDER BY Email;

-- return the artists name and total track count of top 10 rocks band

SELECT 
    a.artist_id AS ID,
    a.name AS Name,
    COUNT(a.artist_id) AS `Number of songs`
FROM
    artist AS a
        JOIN
    album2 AS al ON a.artist_id = al.artist_id
        JOIN
    track AS t ON al.album_id = t.album_id
        JOIN
    genre AS g ON t.genre_id = g.genre_id
WHERE
    g.name LIKE 'Rock'
GROUP BY ID , Name
ORDER BY `Number of songs` DESC
LIMIT 10;

-- Return the name and millisecond more the avegrage for each track. order by the song length wth the longest song listed first

SELECT 
    name AS Song_Name, milliseconds AS Song_length
FROM
    track
WHERE
    milliseconds > (SELECT 
            AVG(milliseconds) AS avg_track
        FROM
            track)
ORDER BY milliseconds DESC;


-- Find how much money spent by each customer on artist. return artiststname,customername and total spent
SELECT  a.artist_id,
    CONCAT(c.first_name, ' ', last_name) AS Customer_Name,
    a.name AS Artist_name,
    ROUND(SUM(il.quantity * il.unit_price), 2) AS Total_spend
FROM
    customer AS c
        JOIN invoice AS i ON c.customer_id = i.customer_id
        JOIN invoice_line AS il ON i.invoice_id = il.invoice_id
        JOIN track AS t ON il.track_id = t.track_id
        JOIN album2 AS al ON t.album_id = al.album_id
        JOIN artist AS a ON al.artist_id = a.artist_id
GROUP BY c.customer_id , 
		CONCAT(c.first_name, ' ', c.last_name) , 
        a.artist_id , 
        a.name
ORDER BY Total_spend desc;

-- find out most popular genre for each country along with the highest purchase amount
select * from customer;
select * from genre;
select * from invoice_line;

WITH cte AS (
    SELECT
        SUM(il.quantity) AS Purchases,
        c.country,
        g.name,
        g.genre_id,
        ROW_NUMBER() OVER (PARTITION BY c.country ORDER BY COUNT(il.invoice_id)) AS row_num
    FROM customer AS c
    JOIN invoice AS i ON c.customer_id = i.customer_id
    JOIN invoice_line AS il ON i.invoice_id = il.invoice_id
    JOIN track AS t ON il.track_id = t.track_id
    JOIN genre AS g ON t.genre_id = g.genre_id
    GROUP BY c.country, g.name, g.genre_id
    ORDER BY c.country ASC, Purchases DESC
)

 select * from cte
 where row_num<=1;
 
--  Top most spent customer by country
WITH customer_totals AS (
    SELECT 
        i.customer_id, 
        i.billing_country, 
        CONCAT(c.first_name, ' ', c.last_name) AS Name, 
        ROUND(SUM(i.total), 2) AS Total
    FROM customer AS c
    JOIN invoice AS i ON c.customer_id = i.customer_id
    JOIN invoice_line AS il ON i.invoice_id = il.invoice_id
    JOIN track AS t ON il.track_id = t.track_id
    JOIN genre AS g ON t.genre_id = g.genre_id
    GROUP BY i.customer_id, i.billing_country, Name
),
max_totals AS (
    SELECT 
        billing_country, 
        MAX(Total) AS MaxTotal
    FROM customer_totals
    GROUP BY billing_country
)
SELECT 
    
    c.billing_country, 
    c.Name, 
    m.MaxTotal
FROM customer_totals c
JOIN max_totals m ON c.billing_country = m.billing_country AND c.Total = m.MaxTotal
ORDER BY m.MaxTotal DESC;

    
 