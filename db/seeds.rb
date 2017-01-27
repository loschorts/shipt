# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

ActiveRecord::Base.transaction do

3.times do 
	Customer.create! first_name: Faker::Name.first_name, 
		last_name: Faker::Name.last_name
end 

Category.create! name: "Dairy" #1 
Category.create! name: "Produce" #2
Category.create! name: "Deli" #3 
Category.create! name: "Meat, Poultry, and Seafood" #4

Product.create! name: "Prosciutto", 
	quantity: 10, 
	unit: "lb",
	category_ids: [3, 4]
Product.create!	name: "Sliced Gouda (Packages)",
	quantity: 5,
	category_ids: [1, 3]
Product.create!	name: "Apple",
	quantity: 10,
	category_ids: [2]
Product.create!	name: "Potato",
	quantity: 10,
	unit: "lb",
	category_ids: [2]
Product.create!	name: "Shrimp",
	quantity: 5,
	unit: "lb",
	category_ids: [4]
Product.create!	name: "Half and Half",
	quantity: 2,
	category_ids: [1]
end
