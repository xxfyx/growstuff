class Order < ActiveRecord::Base
  attr_accessible :member_id, :completed_at
  belongs_to :member

  has_many :order_items

  default_scope order('created_at DESC')
end
