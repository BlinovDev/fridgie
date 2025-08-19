class FridgesController < ApplicationController
  # Require user to be logged in for all fridge actions
  before_action :authenticate_user!
  before_action :set_fridge, only: [:show, :edit, :update, :destroy]

  # GET /fridges
  # Lists current user's fridges
  def index
    @fridges = current_user.fridges.order(created_at: :desc)
  end

  # GET /fridges/:id
  # Shows a single fridge with its items
  def show
    @fridge_item = FridgeItem.new # for the inline add form

    @fridge = current_user.fridges.find(params[:id])
    @products = @fridge.fridge_items.order(:name).pluck(:name)

    @recipes = Recipe
                 .ranked_by_products(@products)
                 .order(Arel.sql("match_count DESC"), created_at: :desc)
                 .page(params[:page])
  end

  # GET /fridges/new
  # Renders creation form
  def new
    @fridge = current_user.fridges.new
  end

  # POST /fridges
  # Persists a new fridge owned by current_user
  def create
    @fridge = current_user.fridges.new(fridge_params)
    if @fridge.save
      redirect_to @fridge, notice: "Fridge created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /fridges/:id/edit
  # Renders edit form for a fridge
  def edit
  end

  # PATCH/PUT /fridges/:id
  # Updates fridge attributes
  def update
    if @fridge.update(fridge_params)
      redirect_to @fridge, notice: "Fridge updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /fridges/:id
  # Deletes a fridge (and its items)
  def destroy
    @fridge.destroy
    redirect_to fridges_path, notice: "Fridge deleted."
  end

  private

  # Loads a fridge scoped to the current user to prevent unauthorized access
  def set_fridge
    @fridge = current_user.fridges.find(params[:id])
  end

  # Strong params for fridge creation/update
  def fridge_params
    params.require(:fridge).permit(:name)
  end
end
