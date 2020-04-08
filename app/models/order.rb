class Order < ActiveRecord::Base
  validates :shopify_id, uniqueness: true

end