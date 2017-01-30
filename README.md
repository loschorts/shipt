

# SQL Query for Counting Customer Purchases by Category

```sql

SELECT customers.id as customer_id, customers.first_name as customer_first_name,
categories.id as category_id, categories.name as category_name,
count(line_items.id) as number_purchased 

FROM customers 

INNER JOIN orders ON orders.customer_id = customers.id 
INNER JOIN line_items ON line_items.order_id = orders.id 
INNER JOIN products ON products.id = line_items.product_id 
INNER JOIN category_products ON category_products.product_id = products.id 
INNER JOIN categories ON categories.id = category_products.category_id 

GROUP BY customers.id, categories.id

ORDER BY customers.id, categories.id;

```

And the same query in **ActiveRecord**: 

```rb
class Customer < ApplicationRecord
	has_many :orders
	has_many :products, through: :orders
	has_many :categories, through: :products

	def self.purchases_by_category
		query = [
			"customers.id as customer_id",
			"customers.first_name as customer_first_name",
			"categories.id as category_id",
			"categories.name as category_name",
			"count(line_items.id) as number_purchased"
		]
		Customer.joins(:categories)
			.select(query.join(", "))
			.group("customers.id, categories.id")
			.order("customers.id, categories.id")
	end

end
```

# API Endpoints

API endpoints are all name-spaced under `/api` in order to avoid collision with client-facing routes. They return JSON data. Collections are formatted as arrays to keep with convention.

## api/products/sales

This endpoint returns the quantity of each product sold during the specified timeframe, grouped day, week, or month. The data is represented as an array of intervals, each with a starting date and a sub-array of sales completed for the specified interval.

Example: https://shipt.com/api/products/sales?start_date=08-13-2016&end_dat
[e=12-31-2016&interval=month

### params

- **`start_date`**, **`end_date`** 
	- specifies the timeframe to search
	- dates are inclusive
	- format: MM-DD-YYYY
	- default: start_date: '1-1-1', end_date: '9-9-9999'
- **`interval`**
	- groups sales data by the given interval
	- accepted values: 'day', 'week', 'month'
	- default: 'month'

## api/customers/:id/orders

This endpoint returns the orders created by a given customer, including the order status and items included in the order.

Example: https://shipt.com/api/customers/2/orders