class AddActivityToUsers < ActiveRecord::Migration
  def change
    add_column :users, :activity, :boolean, default: false
  end
end
