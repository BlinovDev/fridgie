class Fridge < ApplicationRecord
  belongs_to :user
  has_many :fridge_items, dependent: :destroy

  # Basic validation for the fridge name
  validates :name, presence: true, length: { maximum: 100 }
end
