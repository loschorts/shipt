class LineItem < ApplicationRecord
  belongs_to :order
  belongs_to :product
  
  validates :quantity, presence: true, numericality: {greater_than_or_equal_to: 0}
  has_one :unit, through: :product
end
