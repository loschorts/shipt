# Introduction

I created a Rails application with PostgreSQL database to tackle this project. I
chose Rails because its ORM (ActiveRecord) provides a convenient database query
syntax, and the MVC framework facilitates DRY access to data across multiple API
endpoints. I opted not to use API mode to preserve the possibility that the
application could also be used to serve client-side assets as well.

## To Run

In your terminal: 
```bash
git clone git@github.com:loschorts/shipt.git
cd shipt
bundle
rails s
```

Then open:

- [product sales API example][ex1]
- [customer orders API example][ex2]

[ex1]:localhost:3000/api/product/sales/?start_date=08-01-2016&end_date=12-01-2016&product_ids[]=1&product_ids[]=2&product_ids[]=3
[ex2]:localhost:3000/api/customers/1/orders

## Assumptions

I employed the following assumptions: 

- For the `api/product/sales` API endpoint, an interval starts at the beginning of a
calendar day/week/month, even if the start date does not. For example, a search
from '12-15-16' to '2-14-16' using a 'month' interval will group the results in
intervals `Dec. 15 - 31`, `Jan. 1 - 31`, and `Feb. 1-14`, not `Dec. 15 - Jan. 14`, `Jan.
15 - Feb. 14`.
- An order represents a transaction from cart to checkout.
- Incomplete orders (i.e. orders not checked out) are not considered sold for the
`api/products/sales` API endpoint.
- Empty orders are relevant to the `api/customers/:id/orders` API endpoint.
- An order does not reduce a product's inventory until the order is checked out.
- Orders cannot be checked out if they would reduce a product's inventory below zero.
- For Task #3, I assume the query is a list of all customer purchases grouped by
customer and category. I used `INNER JOIN` because it was the simplest approach
and the prompt did not specify how to treat customers/categories that had no
corresponding entries, i.e. a customer with no purchases in a category, or a
category with no purchases by a customer. The query could be changed to
accomodate such entries by using outer joins on either `customers` or
`categories`. It also could be changed to accept parameters for finding a
specific customer or category's records.

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
- `product_ids[]`: Restricts the results to products with listed ids. Optional.

This endpoint is primarily driven by the `Product#sales_in_timeframe` query on the `Product` model.

```rb

	# app/models/product.rb

	def self.sales_in_timeframe(params)
		products = params[:product_ids]
		query = Order.in_timeframe(params).joins(:products)
		query = query.where("products.id IN (?)", products) if products

		query.select(
			"products.name product_name, products.id product_id, " + 
			"sum(line_items.quantity) units_sold, products.unit")
			.group("products.id")
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

The results are then rendered by the JSON view
`app/views/api/products/sales.json.jbuilder`, which formats them in a nested
manner.


### `api/customers/#id/orders`

This GET request returns the orders for a given customer, listing each order's
items. It relies primarily on `Customer#detailed_orders`, which fetches a
customer's orders and accompanying items.

```rb
	# app/models/customer.rb
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

## Task 3 & 4: Counting Customer Purchases by Category

Please see assumptions above.

The SQL query: 
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

## Additional Questions 1: One-Click Ordering of Lists

A list very closely resembles an order in that it is comprised of line items,
i.e. specific quantities of each product.

Therefore, I would create a `List` model and `lists` table. A `List` `belongs_to
:customer` and `has_many :line_items`. I would modify my `line_items` table to
be polymorphic, allowing `LineItems` to be associated with either an `Order` or
a `List`.

When a customer adds a list to an order, I would create a duplicate `LineItem`
attached to the `Order` for each line-item in the `List`.

*Pros*:
- DRY Code: Reusing `LineItems` across `Orders` and `Lists` would reduce the application's overall complexity.
- `Lists` can be reused, since they are not treated as transactions like `Orders`.
- `Lists` can be altered without modifying previous orders that used those lists.
If, for example, I had made a `list_orders` join table and used that to get the
`List#line_items` for an `Order` through a `through` association, modifying the
`List#line_items` would rewrite past `Orders` that it was associated with.
Duplicating `LineItems` avoids this problem.

*Cons*:
- Storage: A list-line-item would be duplicated for each order it was attached to,
increasing storage. However, since lists are relatively small, and I want
customers to be able to modify them without altering their past orders, this con
is outweighed.
- No separate orders: Lists would be added to pre-existing orders, meaning that a
customer could not ONLY buy list items if there were already items in their
order. This could be circumvented by allowing a customers to have multiple orders
open at once, though it might complicate the UX.


## Additional Questions 2: Inventory Distribution

Inventory distribution would be handled on a first-checked-out, first-served
basis. Because we can't know when pending orders will be checked-out, if ever,
reserving inventory can't be reasonably done until an order has actually been
placed. During the checkout process, orders requesting product quantities that
can't be fulfilled would be denied.

```rb
	#order.rb
  def checkout! 
  	transaction do 

  		line_items.includes(:product).each do |i|
  			product = i.product
  			product.update!(quantity: product.quantity - i.quantity)
  		end

  		update!(status: STATUS[:checked_out])
  	end

  end 
``` 

In a more refined form, this process would return an error message with a list
of items that couldn't be fulfilled to the end user and ask them how to proceed.

# Plans for Future Development

- Build specs for Models and API endpoints.
- Build Lists feature.
- Incorporate user authentication to protect sensitive endpoints.
- Add support for additional parameters to specify the shape of the returned data
(ex. a `group_by` parameter on `api/products/sales` to specify whether results
should be grouped by interval or product).
- Build an HTML endpoint `api/help` providing information on API usage.

# Conclusion

Thanks for taking the time to review my work. I look forward to hearing from the Shipt team!