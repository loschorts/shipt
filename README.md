

# SQL Query for Counting Customer Purchases by Category

```sql

SELECT customers.id as customer_id, customers.first_name as customer_first_name,
categories.id as category_id, categories.name as category_name,
count(line_items.id) as number_purchased 

FROM customers INNER JOIN orders ON orders.customer_id = customers.id 
INNER JOIN line_items ON line_items.order_id = orders.id 
INNER JOIN products ON products.id = line_items.product_id 
INNER JOIN category_products ON category_products.product_id = products.id 
INNER JOIN categories ON categories.id = category_products.category_id 

GROUP BY customers.id, categories.id
ORDER BY customers.id, categories.id;

```