orders = {}

@order_items.each do |oi|
	order = oi.slice("id", "updated_at", "status", "date_completed")
	item = oi.slice("product_id", "product_name", "quantity", "unit")
	orders[oi["id"]] ||= order
	orders[oi["id"]]["items"] ||= []
	orders[oi["id"]]["items"] << item unless oi["product_id"].nil?
end

orders.keys.each do |id|
	json.set! id, orders[id]
end