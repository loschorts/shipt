class Api::CustomersController < ApplicationController
	def orders
		@customer = Customer.find(params[:id])
		@orders = @customer.orders if @customer
		render json: @orders
	end
end
