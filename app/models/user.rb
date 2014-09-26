class User < ActiveRecord::Base
  has_and_belongs_to_many :products
  has_many :prices

  validates_presence_of :phone
  validates_uniqueness_of :phone, scope: :role

  scope :in_products, lambda { |*products|
    joins(:products).
        where(:products_users => { :product_id => products } )
  }

end
