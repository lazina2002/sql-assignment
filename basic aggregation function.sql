## Basic Aggregate Functions

-- this section is created using Sakila database 
---------------------------------------------------------------------------------
USE sakila;
---------------------------------------------------------------------------------
-- Question 1: Retrieve the total number of rentals made in the Sakila database
SELECT COUNT(*) AS total_rentals FROM rental;
---------------------------------------------------------------------------------
-- Question 2: Find the average rental duration (in days) of movies rented from the Sakila database
SELECT AVG(rental_duration) AS avg_rental_duration FROM film;
---------------------------------------------------------------------------------
-- Question 3: Display the first name and last name of customers in uppercase
SELECT UPPER(first_name) AS first_name_upper, UPPER(last_name) AS last_name_upper FROM customer;
---------------------------------------------------------------------------------
-- Question 4: Extract the month from the rental date and display it alongside the rental ID
SELECT rental_id, MONTH(rental_date) AS rental_month FROM rental;
---------------------------------------------------------------------------------
-- Question 5: Retrieve the count of rentals for each customer
SELECT customer_id, COUNT(*) AS rental_count 
FROM rental 
GROUP BY customer_id;
---------------------------------------------------------------------------------
-- Question 6: Find the total revenue generated by each store
SELECT s.store_id, SUM(p.amount) AS total_revenue 
FROM payment p
JOIN staff s ON p.staff_id = s.staff_id 
GROUP BY s.store_id;
---------------------------------------------------------------------------------
-- Question 7: Determine the total number of rentals for each category of movies
SELECT c.name AS category, COUNT(r.rental_id) AS total_rentals
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY c.name;
---------------------------------------------------------------------------------
-- Question 8: Find the average rental rate of movies in each language
SELECT l.name AS language, AVG(f.rental_rate) AS avg_rental_rate
FROM film f
JOIN language l ON f.language_id = l.language_id
GROUP BY l.name;