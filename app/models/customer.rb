class Customer < ApplicationRecord
	has_many :orders
	has_many :line_items, through: :orders
	has_many :products, through: :orders
	has_many :categories, through: :products

	validates :first_name, :last_name, presence: true

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
