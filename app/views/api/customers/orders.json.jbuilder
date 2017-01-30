# Reformats the raw `@order_details` into an array of `order` objects with nested `line_items`

orders = {}

@order_details.each do |od|
	order = od.slice("order_id", "updated_at", "status", "date_completed")
	order["status"] = Order::STATUS_CODES[order["status"]]
	item = od.slice("product_id", "product_name", "quantity", "unit")
	orders[od["order_id"]] ||= order
	orders[od["order_id"]]["items"] ||= []
	orders[od["order_id"]]["items"] << item unless od["product_id"].nil?
end

sorted = orders.values.sort do |a,b|
	Date.strptime(a["date_completed"], '%m-%d-%Y') <=> 
	Date.strptime(b["date_completed"], '%m-%d-%Y')	
end

json.array! sorted
