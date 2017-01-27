class AddCompletionDateToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :completion_date, :datetime
  end
end
