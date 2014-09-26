class DropTableFarmers < ActiveRecord::Migration
  def change
    drop_table :farmers
  end
end
