class Restaurant < ApplicationRecord
  # Relationships
  has_many :orders
  has_many :users, through: :orders

  # Validations
  validates_presence_of :business_id

  # Methods

end
