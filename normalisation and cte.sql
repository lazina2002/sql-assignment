## Normalisation & CTE 

-- this section is created using Sakila database 
---------------------------------------------------------------------------------
USE sakila;
---------------------------------------------------------------------------------
/*
-- Question 1  Identify a table in the Sakila database that violates 1NF. Explain how you would normalize it to achieve 1NF.  

-- In the Sakila database, a table that could violate **First Normal Form (1NF)** is the `customer` table if it were to store multiple phone numbers in a single field.  

### Violation of 1NF:  1NF requires that all attributes contain atomic (indivisible) values. If the `customer` table has a column like `phone_numbers` storing multiple numbers (e.g., "1234567890, 9876543210"), it violates 1NF.

Normalization to Achieve 1NF:  
To normalize it:
- Create a separate table called `customer_phone`.
- Move phone numbers to this new table, linking them to `customer_id`.  

New Structure:
customer_phone table
| phone_id | customer_id | phone_number |
|----------|------------|--------------|
| 1        | 101        | 1234567890   |
| 2        | 101        | 9876543210   |

Now, each phone number is stored separately, ensuring **atomicity**.

-- Question 2  
Choose a table in Sakila and describe how you would determine whether it is in 2NF.  
If it violates 2NF, explain the steps to normalize it.  

A table violates Second Normal Form (2NF) if:
1. It has **partial dependency (i.e., a non-key attribute depends only on part of a composite primary key).  

Example: `film_actor` table  
| actor_id | film_id | actor_name | film_title |
|----------|---------|------------|------------|
| 1        | 10      | Brad Pitt  | Fight Club |
| 2        | 10      | Edward Norton | Fight Club |

Here, `actor_name` depends only on `actor_id`, and `film_title` depends only on `film_id`. Since the **primary key is (actor_id, film_id)**, this is a **partial dependency**, violating 2NF.

Normalization to Achieve 2NF:
- Remove `actor_name` and `film_title` from `film_actor`.
- Store `actor_name` in the `actor` table.
- Store `film_title` in the `film` table.
- Now, `film_actor` contains only `actor_id` and `film_id`, forming a composite key.


-- Question 3  Identify a table in Sakila that violates 3NF. Describe the transitive dependencies present and outline the steps to normalize the table to 3NF.  

- A table violates Third Normal Form (3NF) if:
- A non-key column is dependent on another non-key column** rather than on the primary key.

### Example: `customer` table
| customer_id | address_id | city | country |
|-------------|-----------|------|---------|
| 1           | 101       | London  | UK  |
| 2           | 102       | Paris   | France |

Here, `country` depends on `city`, which depends on `address_id`, **creating a transitive dependency**.

## Normalization to Achieve 3NF:
- Create a separate `city` table** with `city_id` and `country_id`.
- Modify `customer` to store `city_id` instead of `city` and `country`**.
- Link `city_id` to `country_id` in a separate `country` table**.



-- Question 4  
Take a specific table in Sakila and guide through the process of normalizing it from the initial unnormalized form up to at least 2NF.  

Example: `rental` table (Unnormalized)
| rental_id | customer_id | customer_name | film_id | film_title | rental_date |
|-----------|------------|--------------|---------|-----------|-------------|
| 1         | 101        | John Doe     | 10      | Matrix    | 2024-01-10  |

1NF: Split customer details into `customer` table.
2NF: Ensure no partial dependencies by storing `film_title` in `film` table.

Final `rental` table:
| rental_id | customer_id | film_id | rental_date |
|-----------|------------|---------|-------------|
| 1         | 101        | 10      | 2024-01-10  |

Now, `customer_name` and `film_title` are stored in separate tables.

*/

-- Question 5  Write a query using a CTE to retrieve the distinct list of actor names and the number of films they have acted in from the `actor` and `film_actor` tables.  

WITH actor_films AS (
    SELECT fa.actor_id, a.first_name, a.last_name, COUNT(fa.film_id) AS film_count
    FROM film_actor fa
    JOIN actor a ON fa.actor_id = a.actor_id
    GROUP BY fa.actor_id, a.first_name, a.last_name
)
SELECT * FROM actor_films;


---------------------------------------------------------------------------------
-- Question 6  Create a CTE that combines information from the film and language tables to display the film title, language name, and rental rate.  
WITH film_languages AS (
    SELECT f.title, l.name AS language, f.rental_rate
    FROM film f
    JOIN language l ON f.language_id = l.language_id
)
SELECT * FROM film_languages;

---------------------------------------------------------------------------------
-- Question 7  Write a query using a CTE to find the total revenue generated by each customer (sum of payments) from the customer and payment tables.  
WITH customer_revenue AS (
    SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount) AS total_spent
    FROM customer c
    JOIN payment p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT * FROM customer_revenue;

---------------------------------------------------------------------------------
-- Question 8  Utilize a CTE with a window function to rank films based on their rental duration from the film table.  
WITH film_rank AS (
    SELECT title, rental_duration, 
           RANK() OVER (ORDER BY rental_duration DESC) AS `rank`
    FROM film
)
SELECT * FROM film_rank;

---------------------------------------------------------------------------------
-- Question 9  Create a CTE to list customers who have made more than two rentals, and then join this CTE with the customer table to retrieve additional customer details.  
WITH frequent_customers AS (
    SELECT customer_id, COUNT(*) AS rental_count
    FROM rental
    GROUP BY customer_id
    HAVING COUNT(*) > 2
)
SELECT c.customer_id, c.first_name, c.last_name, fc.rental_count
FROM frequent_customers fc
JOIN customer c ON fc.customer_id = c.customer_id;

---------------------------------------------------------------------------------
-- Question 10  Write a query using a CTE to find the total number of rentals made each month, considering the rental_date from the rental table.  
WITH monthly_rentals AS (
    SELECT MONTH(rental_date) AS rental_month, COUNT(*) AS total_rentals
    FROM rental
    GROUP BY MONTH(rental_date)
)
SELECT * FROM monthly_rentals;

---------------------------------------------------------------------------------
-- Question 11  Create a CTE to generate a report showing pairs of actors who have appeared in the same film together, using the film_actor table.  
WITH actor_pairs AS (
    SELECT fa1.actor_id AS actor1, fa2.actor_id AS actor2, fa1.film_id
    FROM film_actor fa1
    JOIN film_actor fa2 ON fa1.film_id = fa2.film_id AND fa1.actor_id < fa2.actor_id
)
SELECT * FROM actor_pairs;

---------------------------------------------------------------------------------
-- Question 12  Implement a recursive CTE to find all employees in the staff table who report to a specific manager, considering the reports_to column.  
WITH RECURSIVE staff_hierarchy AS (
    SELECT staff_id, first_name, last_name, reports_to
    FROM staff
    WHERE reports_to IS NULL

    UNION ALL

    SELECT s.staff_id, s.first_name, s.last_name, s.reports_to
    FROM staff s
    JOIN staff_hierarchy sh ON s.reports_to = sh.staff_id
)
SELECT * FROM staff_hierarchy;