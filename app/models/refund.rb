class Refund < ActiveRecord::Base
  validates :shopify_id, uniqueness: true
  
end