class CreateTables < ActiveRecord::Migration[5.0]
  def change
    create_table :customers do |t|
      t.string :first_name
      t.string :last_name

      t.timestamps
    end

    create_table :orders do |t|
      t.references :customer, foreign_key: true
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    create_table :categories do |t|
      t.string :name, null: false

      t.timestamps
    end

    create_table :products do |t|
      t.string :name, null: false
      t.float :quantity, default: 0
      t.string :unit

      t.timestamps
    end

    create_table :category_products do |t|
    	t.references :category, foreign_key: true
    	t.references :product, foreign_key: true

    	t.timestamps
    end

    add_index :category_products, [:category_id, :product_id], unique: true

    create_table :line_items do |t|
      t.references :order, foreign_key: true
      t.references :product, foreign_key: true
      t.float :quantity, null: false, default: 0
      t.timestamps
    end
  end
end
