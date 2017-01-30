class Api::ProductsController < ApplicationController
	before_action :set_default_params

	def sales
		@sales = Product.sales_in_timeframe(timeframe_params).as_json
		# render json: @sales
	end

	private

	def timeframe_params
		params.permit(:start_date, :end_date, :interval, :group_by, product_ids: [])
	end
	
	# Injects default values for params not provided.
	def set_default_params
		intervals = %w(day week month)
		params[:interval] = intervals.detect {|i| i == params[:interval]} || "week"

		params[:start_date] ||= "1-1-1"
		params[:end_date] ||= "9-9-9999"
	end
end
