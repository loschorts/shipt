class Api::ProductsController < ApplicationController
	before_action :ensure_interval_params, only: [:sales]

	def sales
		@sales = Product.sales_in_timeframe(timeframe_params).as_json
		@params = timeframe_params
	end

	private

	def timeframe_params
		params.permit(:start_date, :end_date, :interval, :group_by, product_ids: [])
	end
	
	def ensure_interval_params
		intervals = %w(day week month)
		params[:interval] = intervals.detect {|i| i == params[:interval]} || "month"

		params[:start_date] ||= "1-1-1"
		params[:end_date] ||= "9-9-9999"
	end
end
