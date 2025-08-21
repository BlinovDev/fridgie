# app/helpers/recipes_helper.rb
module RecipesHelper
  # Returns best image source for a recipe (local path, remote URL, or placeholder).
  def recipe_image_src(recipe)
    recipe.image_path.presence || recipe.image_url.presence || asset_path("placeholder_recipe.jpg")
  end

  # Splits ingredients into a normalized array.
  # Accepts Array or String (comma/semicolon/newline separated).
  # - strips whitespace
  # - removes blanks
  # - uniq case-insensitively
  def parse_ingredients(ingredients)
    raw =
      case ingredients
      when String
        ingredients.split(/[,;\n\r\t]+/)
      when Array
        ingredients
      else
        []
      end

    cleaned = raw.map { |v| v.to_s.strip }.reject(&:blank?)
    seen = Set.new
    cleaned.each_with_object([]) do |item, acc|
      key = item.downcase
      next if seen.include?(key)
      seen << key
      acc << item
    end
  end

  # Renders each ingredient as a badge.
  def render_ingredients(ingredients, matched = [], limit: 10, max_len: 45, tooltip: true)
    items = Array(ingredients)
    return "".html_safe if items.empty?

    normalized_matches = Array(matched).map { |m| m.to_s.downcase.strip }.reject(&:blank?)
    match_set = normalized_matches.to_set

    matches = lambda do |ing|
      down = ing.to_s.downcase
      match_set.any? { |m| down.include?(m) || m.include?(down) }
    end

    sorted = items.sort_by { |ing| [matches.call(ing) ? 0 : 1, ing.to_s.downcase] }

    limited = limit.nil? ? sorted : sorted.first(limit.to_i)

    badges = limited.map do |ing|
      text = ing.to_s
      is_match = matches.call(ing)

      css = ["badge", "me-1", "mb-1", (is_match ? "bg-success text-white" : "bg-secondary")]

      display_text =
        if max_len.present? && max_len.to_i > 0 && text.length > max_len.to_i
          "#{text[0...max_len.to_i]}…"
        else
          text
        end

      attrs = { class: css.join(" ") }
      attrs[:title] = text if tooltip && display_text != text

      content_tag(:span, display_text, attrs)
    end

    safe_join(badges, " ")
  end
end
