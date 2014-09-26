class Product < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :prices
  validates_uniqueness_of :name
  validates_presence_of :name

  before_save {|product| product.name = product.name.downcase}

end
