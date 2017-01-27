class CategoryProduct < ApplicationRecord
	belongs_to :category
	belongs_to :product

	validates_uniqueness_of :category_id, scope: :product_id
end
