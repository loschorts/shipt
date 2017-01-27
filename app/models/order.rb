class Order < ApplicationRecord
	STATUS = {
		in_cart: 0,
		assembling: 1,
		awaiting_delivery: 2,
		en_route: 3,
		delivered: 4,
		cancelled: 5
	}

	has_many :line_items
	has_many :products, through: :line_items
	has_many :categories, through: :products
  belongs_to :customer
  validates :status, inclusion: {in: 0..STATUS.length}

  def add(product, quantity)
  	product = product.is_a?(String) ? 
  		Product.find_by(name: product) : Product.find(product)
  	line_items.create! product: product, quantity: quantity
  end

  def self.inchoate
  	where("status < #{STATUS[:assembling]}")
  end

  def self.in_fulfillment
  	where("status BETWEEN #{STATUS[:assembling]} AND #{STATUS[:en_route]} ")
  end

  def self.completed
  	where(status: STATUS[:delivered])
  end

  def self.terminated
  	where("status > #{STATUS[:delivered]}")
  end

  def self.in_timeframe(params)
    start_date = params[:start_date] || DateTime.new(1,1,1)
    end_date = params[:end_date] || DateTime.new(9999,12,31)

    Order.completed.where(completion_date: start_date..end_date)
  end

  def self.by_week
    select
  end

  def checkout! 
  	transaction do 

  		line_items.includes(:product).each do |i|
  			product = i.product
  			product.update!(quantity: product.quantity - i.quantity)
  		end

  		update!(status: STATUS[:assembling])
  	end

  end

  def deliver!
  	update!(status: STATUS[:awaiting_delivery])
  end

  def pick_up!
  	update!(status: STATUS[:en_route])
  end

  def drop_off!
  	update!(status: STATUS[:delivered], completion_date: DateTime.now)

  end

  def get_status
  	STATUS[status]
  end

  # for debugging

  def to_s
  	line_items.includes(:product).each do |i| 
  		puts "#{i.product.name}: #{i.quantity} #{i.unit}"
  	end
  end
end
