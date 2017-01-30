class Order < ApplicationRecord
	STATUS = {
		in_cart: 0,
    checked_out: 1,
    delivered: 2
	}

  STATUS_CODES = STATUS.invert

	has_many :line_items
	has_many :products, through: :line_items
	has_many :categories, through: :products
  belongs_to :customer
  validates :status, inclusion: {in: 0..STATUS.length}

  def add(product, quantity)
  	product = product.is_a?(String) ? 
  		Product.find_by(name: product) : Product.find(product)

    in_cart = line_items.find_by(product_id: product.id)

    if in_cart
      in_cart.update!(quantity: in_cart.quantity + quantity)
    else
    	line_items.create! product: product, quantity: quantity
    end
  end

  def self.in_timeframe(params)

    start_date = Date.strptime(params[:start_date], '%m-%d-%Y') 
    end_date = Date.strptime(params[:end_date], '%m-%d-%Y')
    interval = params[:interval]

    Order
      .where(status: Order::STATUS[:checked_out])
      .where(completion_date: start_date..end_date)
      .select("to_char(date_trunc('#{interval}', completion_date), 'MM-DD-YYYY') as interval_start")
      .group("interval_start")
  end

  def checkout! 
  	transaction do 

  		line_items.includes(:product).each do |i|
  			product = i.product
  			product.update!(quantity: product.quantity - i.quantity)
  		end

  		update!(status: STATUS[:checked_out])
  	end

  end

  def set_status(status)
  	update!(status: STATUS[status])
  end

  def get_status
  	STATUS[status]
  end

  def self.include_empties
    self
    .joins("LEFT OUTER JOIN line_items ON line_items.order_id = orders.id")
    .joins("INNER JOIN customers ON orders.customer_id = customers.id")
    .joins("INNER JOIN products ON products.id = line_items.product_id")
    .joins("INNER JOIN category_products ON category_products.product_id = products.id")
    .joins("INNER JOIN categories ON categories.id = category_products.category_id")
    .select("distinct(line_items.id)")
  end

  def to_s
  	line_items.includes(:product).each do |i| 
  		puts "#{i.product.name}: #{i.quantity} #{i.unit}"
  	end
  end

end
