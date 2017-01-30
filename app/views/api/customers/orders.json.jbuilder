orders = {}

@order_details.each do |od|
	order = od.slice("id", "updated_at", "status", "date_completed")
	item = od.slice("product_id", "product_name", "quantity", "unit")
	orders[od["id"]] ||= order
	orders[od["id"]]["items"] ||= []
	orders[od["id"]]["items"] << item unless od["product_id"].nil?
end

json.array! orders.values
