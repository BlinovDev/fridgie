class FridgeItemsController < ApplicationController
  # Only authenticated users can modify fridges and their items
  before_action :authenticate_user!
  before_action :set_fridge

  # POST /fridges/:fridge_id/fridge_items
  # Adds a new item (product) to the fridge
  def create
    @fridge_item = @fridge.fridge_items.new(fridge_item_params)
    if @fridge_item.save
      redirect_to @fridge, notice: "Item added."
    else
      # Re-render the fridge show page with errors
      @fridge_item ||=
        @fridge.fridge_items.new # ensure variable is present for view
      flash.now[:alert] = @fridge_item.errors.full_messages.to_sentence
      render "fridges/show", status: :unprocessable_entity
    end
  end

  # DELETE /fridges/:fridge_id/fridge_items/:id
  # Removes an item from the fridge
  def destroy
    item = @fridge.fridge_items.find(params[:id])
    item.destroy
    redirect_to @fridge, notice: "Item removed."
  end

  private

  # Loads the fridge owned by the current user to avoid cross-account access
  def set_fridge
    @fridge = current_user.fridges.find(params[:fridge_id])
  end

  # Strong params for creating items
  def fridge_item_params
    params.require(:fridge_item).permit(:name)
  end
end
