require 'active_support/concern'

module Breakdown
  extend ActiveSupport::Concern


  included do

  def self.by_week(params)
    select("TRUNC(DATE_PART('DAY', #{params[:end_date]} - #{params[:start_date]})/7) as week_number")
  end 

  class_methods do 


end
