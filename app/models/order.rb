class Order < ApplicationRecord
	STATUSES = {
		shopping: 0,
		assembling: 1,
		awaiting_delivery: 2,
		en_route: 3,
		delivere: 4	
	}

	has_many :line_items
  belongs_to :customer
  validates :status, inclusion: {in: 0..STATUSES.length}

  def add(product, quantity)
  	product = product.is_a?(String) ? Product.find_by(name: product) : Product.find(product)
  	self.line_items.create! product: product, quantity: quantity
  end

  def checkout!
  	self.transaction do 
  		line_items.each do |i|
  			product = i.product
  			product.update!(quantity: product.quantity - i.quantity)
  		end

  		self.update!(status: STATUSES[:assembling])
  	end
  end

  def deliver!
  	self.update!(status: STATUSES[:awaiting_delivery])
  end

  def pick_up!
  	self.update!(status: STATUSES[:en_route])
  end

  def get_status
  	STATUSES[self.status]
  end

  def to_s
  	line_items.each { |i| puts "#{i.product.name}: #{i.quantity} #{i.unit}" }
  end
end
