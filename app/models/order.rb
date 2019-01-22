class Order < ApplicationRecord
  # Relationships
  belongs_to :user
  belongs_to :restaurant

  # Validations
  validates_presence_of :date, :user_latitude, :user_longitude
  validates_date :date

  # Scopes
  scope :chronological, -> { order('date') }

  # Methods

end
