class Customer < ApplicationRecord
	has_many :orders
	has_many :line_items, through: :orders
	has_many :products, through: :orders
	has_many :categories, through: :products

	validates :first_name, :last_name, presence: true

	def count_line_items_for(category)
		categories
			.group(:name)
			.where(name: category)
			.count(:line_items)
	end

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
	end

end

Customer.first.orders


