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

@params.keys.each do |param|
	json.set!(param, @params[param])
end

sorted = intervals.values.sort do |a,b|
	Date.strptime(a["interval_start"], '%m-%d-%Y') <=> 
	Date.strptime(b["interval_start"], '%m-%d-%Y')	
end

json.intervals do 
	json.array! sorted
end
