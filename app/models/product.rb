class Product < ApplicationRecord
	has_many :line_items
	has_many :category_products
	has_many :categories, through: :category_products
	validates :name, presence: true, uniqueness: true

	validates :name, :quantity, presence: true
	validates :quantity, 
		numericality: {
			greater_than_or_equal_to: 0,
			message: "#{self.name} has insufficient quantity"
		}

end
