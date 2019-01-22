class User < ApplicationRecord
  # Use built-in rails support for password protection
  has_secure_password

  # Relationships
  has_many :orders
  has_many :restaurants, through: :orders

  # Validations
  validates_presence_of :first_name, :last_name, :phone
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates_presence_of :password, :on => :create
  validates_presence_of :password_confirmation, :on => :create
  validates_confirmation_of :password, message: "does not match"
  validates_length_of :password, :minimum => 4, message: "must be at least 4 characters long", :allow_blank => true
  validates_format_of :phone, with: /\A(\d{10}|\(?\d{3}\)?[-. ]\d{3}[-.]\d{4})\z/, message: "should be 10 digits (area code needed) and delimited with dashes only"

  # Scopes
  scope :alphabetical, -> { order('last_name, first_name') }

  # Methods
  def name
    last_name + ", " + first_name
  end

end
