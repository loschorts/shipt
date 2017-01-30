# Reformats the raw `@order_details` into an array of `order` objects with nested `line_items`

orders = {}

@order_details.each do |od|
	order = od.slice("id", "updated_at", "status", "date_completed")
	order["status"] = Order::STATUS_CODES[order["status"]]
	item = od.slice("product_id", "product_name", "quantity", "unit")
	orders[od["id"]] ||= order
	orders[od["id"]]["items"] ||= []
	orders[od["id"]]["items"] << item unless od["product_id"].nil?
end

json.array! orders.values
