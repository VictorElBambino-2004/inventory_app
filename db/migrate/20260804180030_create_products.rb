class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :sku
      t.decimal :price
      t.integer :stock
      t.integer :low_stock_threshold
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
