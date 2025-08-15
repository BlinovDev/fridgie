class Recipe < ApplicationRecord
  has_many :recipe_ingredients
  has_many :ingredients, through: :recipe_ingredients

  scope :search_by_products, ->(products) do
    next all if products.blank?

    products.reduce(all) do |rel, product|
      rel.where("ingredients_list::text ILIKE ?", "%#{sanitize_sql_like(product)}%")
    end
  end
end
