class RecipesController < ApplicationController
  def index
    # most of these data manipulations is for additional protection
    products = Array(params[:products]).map(&:to_s).map(&:strip).reject(&:blank?).uniq.first(10)

    @recipes = Recipe.search_by_products(products).order(created_at: :desc).page(params[:page])
  end

  def show
    @recipe = Recipe.find(params[:id])
  end

  # Ranks recipes by how many fridge items match their ingredients (partial ILIKE).
  # Returns all recipes, ordered by match_count DESC (ties broken by created_at).
  def search_from_fridge
    @fridge   = current_user.fridges.find(params[:fridge_id])
    @products = @fridge.fridge_items.order(:name).pluck(:name)

    @recipes = Recipe
                 .ranked_by_products(@products)
                 .order(Arel.sql("match_count DESC"), created_at: :desc)
                 .page(params[:page])

    # Reuse recipes/index view to render results
    render :index
  end

  private

  # Normalizes products coming from tag UI (AND search)
  def set_products
    @products = Array(params[:products])
                  .map(&:to_s).map(&:strip)
                  .reject(&:blank?).uniq.first(10)
  end
end
