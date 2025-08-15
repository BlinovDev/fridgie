class RecipesController < ApplicationController
  def index
    # most of these data manipulations is for additional protection
    products = Array(params[:products]).map(&:to_s).map(&:strip).reject(&:blank?).uniq.first(10)

    @recipes = Recipe.search_by_products(products).order(created_at: :desc).page(params[:page])
  end

  def show
    @recipe = Recipe.find(params[:id])
  end
end
