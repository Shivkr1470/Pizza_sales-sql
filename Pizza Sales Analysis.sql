create database pizzahut;

use pizzahut;

-- Imported Table "pizzas" and "pizza_types" from option "Data Table Import Wizard"

-- Create Table for "orders" table importing
create table orders (
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id) );


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.3/Uploads/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
#(order_id, date, time)
IGNORE 1 ROWS;

--- Importing Table 'order_details'
create table order_details (
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id) );

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.3/Uploads/order_details.csv'
INTO TABLE order_details
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
#(order_details_id, order_id, pizza_id, quantity)
IGNORE 1 ROWS;


-- Questions for Analysis

#Q1. Retrieve the total number of orders placed.

SELECT COUNT(order_id) AS total_order 
FROM orders;


#Q2. Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;


#Q3. Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


#Q4. Identify the most common pizza size ordered.

select pizzas.size, count(order_details.order_details_id) as order_count
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size order by order_count desc;

#Q5. List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;


#Q6. Find the total quantity of each pizza category ordered.

SELECT 
    pz.category, SUM(od.quantity) AS total_quantity
FROM
    pizza_types AS pz
        JOIN
    pizzas AS p ON pz.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY pz.category
ORDER BY total_quantity DESC;


#Q7. Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY hour;


#Q8. Find the category-wise distribution of pizzas.

SELECT category, COUNT(name) AS count
FROM pizza_types
GROUP BY category;


#Q9. Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT ROUND(AVG(quantity),0) AS avg_order_per_day FROM
(SELECT o.date, SUM(od.quantity) AS quantity 
FROM orders AS o
JOIN order_details AS od
ON o.order_id = od.order_id
GROUP BY o.date) AS order_quantity;


#Q10. Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pt.name, ROUND(SUM(od.quantity * p.price), 2) AS revenue
FROM
    order_details AS od
        JOIN
    pizzas AS p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;


#Q11. Analyze the cumulative revenue generated over time.

SELECT 
    date,
    SUM(revenue) OVER (ORDER BY date) AS cum_revenue
FROM (
    SELECT 
        o.date, 
        SUM(od.quantity * p.price) AS revenue
    FROM orders AS o
    JOIN order_details AS od ON od.order_id = o.order_id
    JOIN pizzas AS p ON od.pizza_id = p.pizza_id
    GROUP BY o.date
) AS sales;

# Q12.Top 3 Pizza Sizes by Quantity Sold

SELECT 
    pizzas.size, SUM(order_details.quantity) AS total_sold
FROM
    pizzas
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY total_sold DESC
LIMIT 3;

# Q13.Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category,
round(sum(order_details.quantity * pizzas.price) / (select 
round(sum(order_details.quantity * pizzas.price ),2) as total_sales
from order_details join pizzas
on pizzas.pizza_id = order_details.pizza_id)*100,2) as revenue
from pizza_types join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id 
group by pizza_types.category order by revenue desc;



