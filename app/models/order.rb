class Order < ApplicationRecord
	has_many :line_items
  belongs_to :customer
  validates :status, inclusion: {in: [0,1,2]}
end
