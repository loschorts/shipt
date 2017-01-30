intervals = {}

@sales.each do |sale|
	start = sale.delete("interval_start")
	sale.delete("id")
	intervals[start] ||= {
		"interval_start" => start, 
		"sales" => []
	}
	intervals[start]["sales"].push(sale)
end

json.array! intervals.values