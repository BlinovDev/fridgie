class FridgeItem < ApplicationRecord
  belongs_to :fridge

  # Normalize and validate name
  before_validation :strip_name

  validates :name, presence: true, length: { maximum: 100 }
  # Prevent duplicates within the same fridge (case-insensitive)
  validates :name, uniqueness: { scope: :fridge_id, case_sensitive: false }

  private

  # Ensures consistent name input (e.g., trims whitespace)
  def strip_name
    self.name = name.to_s.strip
  end
end
