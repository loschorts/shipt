

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

## api/products/sales

[example](http://localhost:3000/api/products/sales?start_date=08-13-2016&end_dat
[e=12-31-2016&interval=month)

### params

- **`start_date`**, **`end_date`**: 
	- format: MM-DD-YYYY
	- inclusive
- **`interval`**: 
	- groups sales data by the given interval
	- accepted values: `day`, `week`, `month`


### Formatting

The data is purposefully left in an un-nested array in order to be use-agnostic;
future improvement could be made by accepting a "group_by" parameter that allows
the information to be grouped by time-unit, product, category, etc.
