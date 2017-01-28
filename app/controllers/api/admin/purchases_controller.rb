class Api::Admin::PurchasesController < ApplicationController

	before_action :validate_params

	def index
		@purchases = Product.in_timeframe(timeframe_params)
		render json: @purchases
	end

	def timeframe_params
		params.permit(:start_date, :end_date, :interval, product_ids: [])
	end

	private

	# Validates the interval to prevent SQL injection and injects default values.
	def validate_params
		intervals = %w(day week month)
		params[:interval] = intervals.detect {|i| i == params[:interval]} || "week"

		params[:start_date] ||= "1-1-1"
		params[:end_date] ||= "9-9-9999"
	end
end
