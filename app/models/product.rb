class Product < ApplicationRecord
	has_many :line_items
	has_many :category_products
	has_many :categories, through: :category_products
	validates :name, presence: true, uniqueness: true

	validates :name, :quantity, presence: true
	validate :sufficient_stock

	def self.sales_in_timeframe(params)
		products = params[:product_ids]
		query = Order.in_timeframe(params).joins(:products)
		query = query.where("products.id IN (?)", products) if products

		query.select("products.name product_name, products.id product_id, sum(line_items.quantity) units_sold, products.unit").group("products.id")
	end

	private

	def sufficient_stock
		errors.add(:stock, "#{name} has insufficient stock.") if quantity < 0
	end

end
