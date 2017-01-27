class Api::Admin::PurchasesController < ApplicationController
	def index
		base = params[:id] ? Product : Product.find(params[:id])
		Order.in_timeframe(timeframe_params)
	end

	def timeframe_params
		params.require(:product).permit(:start_date, :end_date, :unit)
	end
end
