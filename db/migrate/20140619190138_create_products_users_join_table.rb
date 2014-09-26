class CreateProductsUsersJoinTable < ActiveRecord::Migration
  def change
    create_table :products_users, :id => false do |t|
      t.references :user
      t.references :product
    end

    add_index :products_users, [:user_id, :product_id], :unique => true
  end
end
