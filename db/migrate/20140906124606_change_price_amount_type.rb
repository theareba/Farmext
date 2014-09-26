class ChangePriceAmountType < ActiveRecord::Migration
  def change
    change_column :prices, :amount, :string
  end
end
