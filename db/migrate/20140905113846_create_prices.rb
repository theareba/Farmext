class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|
      t.string :amount
      t.references :product, index: true
      t.integer :user_id

      t.timestamps
    end
  end
end
