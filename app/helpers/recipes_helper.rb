module RecipesHelper
  # Returns best image source for a recipe (local path, remote URL, or placeholder).
  def recipe_image_src(recipe)
    recipe.image_path.presence || recipe.image_url.presence || asset_path("placeholder_recipe.jpg")
  end

  # Splits ingredients string into an array of normalized tokens.
  # You can adapt split pattern depending on your data.
  def parse_ingredients(ingredients)
    return [] if ingredients.blank?

    ingredients.map(&:to_s).map(&:strip).reject(&:blank?).uniq
  end

  # Renders each ingredient as a badge.
  # Highlights those present in the "matched" array.
  def render_ingredients(ingredients, matched, limit: 10, max_len: 45)
    return "" if ingredients.blank?

    normalized = Array(matched).map(&:to_s).map(&:downcase)

    # Sort so that matches come first
    sorted = ingredients.sort_by do |ing|
      down = ing.to_s.downcase
      normalized.any? { |m| down.include?(m) || m.include?(down) } ? 0 : 1
    end

    # Limit the number of displayed ingredients
    limited = sorted.first(limit)

    safe_join(limited.map do |ing|
      down = ing.to_s.downcase
      css = normalized.any? { |m| down.include?(m) || m.include?(down) } ? "bg-success text-white" : "bg-secondary"

      # Truncate long ingredient names
      display_text = ing.to_s
      display_text = display_text.length > max_len ? "#{display_text[0...max_len]}..." : display_text

      content_tag(:span, display_text, class: "badge #{css} me-1 mb-1")
    end, " ")
  end
end

