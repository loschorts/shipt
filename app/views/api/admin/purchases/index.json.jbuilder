json.merge! @purchases.as_json.inject({}) do |obj, e| 
	key = e["#{@interval}_start"]
	e.delete("#{@interval}_start")
	obj[key] ||= []
	obj[key] = e
end 