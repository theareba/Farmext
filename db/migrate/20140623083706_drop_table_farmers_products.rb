class DropTableFarmersProducts < ActiveRecord::Migration
  def change
    drop_table :farmers_products
  end
end
