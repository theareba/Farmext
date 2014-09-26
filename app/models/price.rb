class Price < ActiveRecord::Base
  belongs_to :product
  belongs_to :user
  validates_uniqueness_of :product_id, :scope => :user_id
  validates_numericality_of :amount


  before_save {|price| price.amount = price.amount.delete(' ')}


end
