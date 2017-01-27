class Order < ApplicationRecord
	has_many :line_items
  belongs_to :customer
  validates :status, inclusion: {in: [0,1,2]}

  def add(product, quantity)
  	product = product.is_a?(String) ? Product.find_by(name: product) : Product.find(product)
  	self.line_items.create! product: product, quantity: quantity
  end

  def to_s
  	line_items.each { |i| puts "#{i.product.name}: #{i.quantity} #{i.unit}" }
  end
end
