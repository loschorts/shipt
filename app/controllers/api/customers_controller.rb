class Api::CustomersController < ApplicationController
	def orders
		@customer = Customer.find(params[:id])
		@orders = @customer.detailed_orders if @customer
		render json: @orders.as_json
	end
end
