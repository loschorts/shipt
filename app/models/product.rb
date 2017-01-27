class Product < ApplicationRecord
	has_many :line_items
	has_many :category_products
	has_many :categories, through: :category_products
	validates :name, presence: true, uniqueness: true

	validates :name, :quantity, presence: true
	validate :sufficient_stock

	private

	def sufficient_stock
		errors.add(:stock, "#{name} has insufficient stock.") if quantity < 0
	end

end
