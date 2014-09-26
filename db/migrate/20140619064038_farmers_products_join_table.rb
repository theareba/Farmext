class FarmersProductsJoinTable < ActiveRecord::Migration
  def change
    create_table :farmers_products, :id => false do |t|
      t.references :farmer
      t.references :product
    end

    add_index :farmers_products, [:farmer_id, :product_id], :unique => true
  end
end
