class Api::CustomersController < ApplicationController
	def orders
		@customer = Customer.find(params[:id])
		@order_details = @customer.detailed_orders.as_json if @customer
	end
end
