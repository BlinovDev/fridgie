class RenameImageToImageUrlAndAddImagePathToRecipes < ActiveRecord::Migration[8.0]
  def change
    # Rename column :image -> :image_url
    rename_column :recipes, :image, :image_url

    # Add new column for local cached path
    add_column :recipes, :image_path, :string
    add_index  :recipes, :image_path
  end
end
