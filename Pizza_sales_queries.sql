-- Retrieve the total number of orders placed.

SELECT 
    COUNT(*) AS Total_orders
FROM
    orders;

-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS Total_revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;

-- Identify the highest-priced pizza.

SELECT 
    pizza_id, pizzas.pizza_type_id, `name`, price, size, category, ingredients
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
WHERE
    price = (SELECT 
            MAX(price)
        FROM
            pizzas);

-- Identify the most common pizza size ordered.


SELECT 
    size, SUM(quantity) AS total_quantity
FROM
    pizzahut.order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id
GROUP BY size
ORDER BY total_quantity DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.pizza_type_id,
    `name`,
    category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.pizza_type_id , `name` , category
ORDER BY quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) as `Hour`, COUNT(order_id) AS Order_count
FROM
    pizzahut.orders
GROUP BY HOUR(order_time)
ORDER BY 2 DESC;

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    order_date AS `date`,
    SUM(order_details.quantity) AS Total_orders
FROM
    orders
        JOIN
    order_details ON order_details.order_id = orders.order_id
GROUP BY `date`;

WITH avg_pizza_per_day AS(
SELECT 
    order_date AS `date`,
    SUM(order_details.quantity) AS Total_orders
FROM
    orders
        JOIN
    order_details ON order_details.order_id = orders.order_id
GROUP BY `date`
)
SELECT ROUND(AVG(Total_orders),0) AS Avg_pizzas_per_day
FROM avg_pizza_per_day;

-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.pizza_type_id,
    `name`,
    SUM(pizzas.price * order_details.quantity) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.pizza_type_id , `name`
ORDER BY SUM(pizzas.price * order_details.quantity) DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

with percentage_contribution as (
SELECT 
    pizza_types.pizza_type_id,
    pizza_types.`name`,
    SUM(pizzas.price * order_details.quantity) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.pizza_type_id , `name`
ORDER BY SUM(pizzas.price * order_details.quantity) DESC)
,
total_revenue AS (
SELECT 
    SUM(revenue) AS Total_revenue
FROM
    percentage_contribution)
SELECT 
    percentage_contribution.pizza_type_id,
    percentage_contribution.`name`,
    ((percentage_contribution.revenue / total_revenue.Total_revenue) * 100) as percentage_contribution
FROM
    percentage_contribution,
    total_revenue;

-- Analyze the cumulative revenue generated over time.

with cumulative_revenue as
(
SELECT 
    orders.order_date,
    SUM(price * quantity) as Total_Price
FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY orders.order_date
)
SELECT 
    order_date,
    Total_Price, sum(Total_Price) over(order by order_date) as Cumulative_revenue
        from cumulative_revenue;
        
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

WITH REVENUE AS (
SELECT 
    pizza_types.category,
    `name`,
    ROUND(SUM(pizzas.price * order_details.quantity),2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category , `name`
ORDER BY category),
REVENUE_RANK AS(
SELECT REVENUE.*, DENSE_RANK() OVER(PARTITION BY CATEGORY ORDER BY REVENUE DESC) AS `RANK`
FROM REVENUE
)
SELECT REVENUE_RANK.* FROM REVENUE_RANK
WHERE `RANK` <= 3;







