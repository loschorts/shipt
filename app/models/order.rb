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

    in_cart = line_items.find_by(product_id: product.id)

    if in_cart
      in_cart.update!(quantity: in_cart.quantity + quantity)
    else
    	line_items.create! product: product, quantity: quantity
    end
  end

  def self.in_timeframe(params)

    start_date = Date.parse(params[:start_date], '%m-%d-%Y')
    end_date = Date.parse(params[:end_date], '%m-%d-%Y')

    interval = params[:interval] || "week"

    Order.completed
      .where(completion_date: start_date..end_date)
      .select("to_char(date_trunc('#{interval}', completion_date), 'MM-DD-YYYY') as #{interval}_start")
      .group("#{interval}_start")
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

  def set_status(status)
  	update!(status: STATUS[status])
  end

  def get_status
  	STATUS[status]
  end

  def self.completed
    where(status: STATUS[:delivered])
  end

  # for dev convenience

  def to_s
  	line_items.includes(:product).each do |i| 
  		puts "#{i.product.name}: #{i.quantity} #{i.unit}"
  	end
  end

  def self.include_empties
    self
    .joins("LEFT OUTER JOIN customers ON orders.customer_id = customers.id")
    .joins("LEFT OUTER JOIN line_items ON line_items.order_id = orders.id")
    .joins("INNER JOIN products ON products.id = line_items.product_id")
    .joins("INNER JOIN category_products ON category_products.product_id = products.id")
    .joins("INNER JOIN categories ON categories.id = category_products.category_id")
    .select("distinct(line_items.*)")
  end

end
