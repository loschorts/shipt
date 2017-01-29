class Api::ProductsController < ApplicationController
	before_action :coerce_params

	def sales
		@sales = Product.sales_in_timeframe(timeframe_params)
		render json: @sales
	end

	private

	def timeframe_params
		params.permit(:start_date, :end_date, :interval, product_ids: [])
	end
	
	# Validates the interval to prevent SQL injection and injects default values
	# for params not provided.
	def coerce_params
		intervals = %w(day week month)
		params[:interval] = intervals.detect {|i| i == params[:interval]} || "week"

		params[:start_date] ||= "1-1-1"
		params[:end_date] ||= "9-9-9999"
	end
end
