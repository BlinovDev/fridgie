class Recipe < ApplicationRecord
  has_many :recipe_ingredients
  has_many :ingredients, through: :recipe_ingredients

  paginates_per 15

  scope :search_by_products, ->(products) do
    next all if products.blank?

    products.reduce(all) do |rel, product|
      rel.where("ingredients_list::text ILIKE ?", "%#{sanitize_sql_like(product)}%")
    end
  end

  # Ranks all recipes by the number of partial matches against given products.
  # - Does NOT filter out non-matching recipes; returns all with a computed match_count.
  # - Matching is case-insensitive partial match using ILIKE on ingredients_list::text.
  # - When products is empty, match_count will be 0 for all.
  scope :ranked_by_products, ->(raw_products) do
    products = Array(raw_products)
                 .map(&:to_s).map(&:strip)
                 .reject(&:blank?).uniq.first(50)

    if products.empty?
      select("#{table_name}.*, 0 AS match_count")
    else
      # Build SUM of CASE WHEN ILIKE THEN 1 ELSE 0 END for each product
      parts = products.map do |p|
        pattern = "%#{sanitize_sql_like(p)}%"
        "CASE WHEN ingredients_list::text ILIKE #{connection.quote(pattern)} THEN 1 ELSE 0 END"
      end
      sum_sql = parts.join(" + ")
      select("#{table_name}.*, (#{sum_sql}) AS match_count")
    end
  end
end
