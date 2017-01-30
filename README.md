# Introduction

I created a Rails application with PostgreSQL database to tackle this project. I
chose Rails because its ORM (ActiveRecord) provides a convenient database query
syntax, and the MVC framework facilitates DRY access to data across multiple API
endpoints. I opted not to use API mode to preserve the possibility that the
application could also be used to serve client-side assets as well.

## Assumptions

I employed the following assumptions: 

- For the `api/product/sales` API, an interval starts at the beginning of a
calendar day/week/month, even if the start date does not. For example, a search
from '12-15-16' to '2-14-16' using a 'month' interval will group the results in
intervals `Dec. 15 - 31`, `Jan. 1 - 31`, and `Feb. 1-15`, not `Dec. 15 - Jan. 14`, `Jan.
15 - Feb. 14`.
- An order represents a transaction from cart to checkout to delivery.
- Incomplete orders (i.e. orders not checked out) are not considered sold for the
`api/products/sales` API endpoint.
- Empty orders are relevant to the `api/customers/:id/orders` API endpoint.
- An order does reduce a product's inventory until the order is checked out.
- Orders cannot be checked out if they would reduce a product's inventory below zero.

# Key Components

## Models

I created the following models, shown here with key attributes:
- `Customer`: Has many orders.
- `Product`: Represents the inventory of a given product. Has a quantity and an 
optional unit of measurement. Associated with many categories.
- `Order`: A collection of products that comprise a transaction. Has many line-items.
- `LineItem`: Join table between orders and products. Represents the specific products in an
- order, and the quantity ordered of each.
- `Category`: Has many products.
- `CategoryProduct`: Join table representing the has-many:has-many relationship
- between Categories and Products.

## API Endpoints

I created two API endpoints: `api/products/sales`, and
`api/customers/:id/orders`. Both routes are nested under the `api` path in order
to avoid conflicts with client-side routes, and return JSON-formatted responses.

### `api/products/sales'

This GET request returns a breakdown of all product sales by day/week/month. It
is routed to `Api::ProductsController#sales`. It accepts the following parameters:
- `start_date` & `end_date`: `MM-DD-YYYY` formatted date strings. Inclusive. Optional.
- `interval`: String used to set the time interval by which to group results. Accepts 'day',
'week', and 'month'. Defaults to 'month'. 
- `product_ids`: Restricts the results to products with listed ids. Optional.

This endpoint is primarily driven by the `Product#sales_in_timeframe` query on the `Product` model.

```rb

	# app/models/product.rb

	def self.sales_in_timeframe(params)
		products = params[:product_ids]
		query = Order.in_timeframe(params).joins(:products)
		query = query.where("products.id IN (?)", products) if products

		query.select("products.name product_name, products.id product_id, sum(line_items.quantity) units_sold, products.unit").group("products.id")
	end
```

`Product#sales_in_timeframe` itself relies on `Order#in_timeframe`:

```rb
	# app/models/order.rb

  def self.in_timeframe(params)

    start_date = Date.strptime(params[:start_date], '%m-%d-%Y') 
    end_date = Date.strptime(params[:end_date], '%m-%d-%Y')
    interval = params[:interval]

    Order
      .where(status: Order::STATUS[:checked_out])
      .where(completion_date: start_date..end_date)
      .select("to_char(date_trunc('#{interval}', completion_date), 'MM-DD-YYYY') as interval_start")
      .group("interval_start")
  end
```

The results are then rendered by the JSON view `app/views/api/products/sales.json.jbuilder`, which formats them in a nested manner.


### `api/customers/#id/orders`

This GET request returns the orders for a given customer, listing each order's items. It relies primarily on `Customer#detailed_orders`, which fetches a customer's orders and accompanying items.

```rb
	def detailed_orders
		Order.include_empties
			.where(customer_id: self.id)
			.select("orders.id order_id, orders.status, orders.updated_at")
			.select("to_char(orders.completion_date, 'MM-DD-YYYY') date_completed")
			.select("line_items.quantity quantity")
			.select("products.id product_id, products.name product_name, products.unit unit")
	end
```

## Key Files

- `app`
	- `models`
		- `customer.rb`
		- `product.rb`
		- `order.rb`
		- `line_item.rb`
	- `controllers/api/`
		- `customers_controller.rb`
		- `products_controller.rb`
	- `views`
		`customers/orders.json.jbuilder`
		`sales/json.jbuilder`
- `db/migrate/*`
- `config/routes.rb`

# Specific Prompt Responses

## SQL Query for Counting Customer Purchases by Category

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

## One-Click Ordering

*Pros*:
*Cons*:

## Inventory Distribution



# Plans for Future Development

- Build specs for Models and API endpoints.
- Incorporate user authentication to protect sensitive endpoints.
- Add support for additional parameters to specify the shape of the returned data
(ex. a `group_by` parameter on `api/products/sales` to specify whether results
should be grouped by interval or product).
- Build an HTML endpoint `api/help` providing information on API usage.