intervals = {}

@sales.each do |sale|
	start = sale["interval_start"]
	sale.delete("id")
	intervals[start] ||= {
		"interval_start" => sale.delete("interval_start"), 
		"sales" => []
	}
	intervals[start]["sales"].push(sale)
end

json.array! intervals.values