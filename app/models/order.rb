class Order < ApplicationRecord
	STATUSES = {
		shopping: 0,
		assembling: 1,
		awaiting_delivery: 2,
		en_route: 3,
		delivered: 4,
		cancelled: 5
	}

	has_many :line_items
  belongs_to :customer
  validates :status, inclusion: {in: 0..STATUSES.length}

  def add(product, quantity)
  	product = product.is_a?(String) ? 
  		Product.find_by(name: product) : Product.find(product)
  	line_items.create! product: product, quantity: quantity
  end

  def checkout! 
  	transaction do 

  		line_items.includes(:product).each do |i|
  			product = i.product
  			product.update!(quantity: product.quantity - i.quantity)
  		end

  		update!(status: STATUSES[:assembling])
  	end

  end

  def deliver!
  	update!(status: STATUSES[:awaiting_delivery])
  end

  def pick_up!
  	update!(status: STATUSES[:en_route])
  end

  def drop_off!
  	update!(status: STATUSES[:delivered])
  end

  def get_status
  	STATUSES[status]
  end



  def to_s
  	line_items.includes(:product).each { |i| puts "#{i.product.name}: #{i.quantity} #{i.unit}" }
  end
end
