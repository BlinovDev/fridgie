class CreateRecipes < ActiveRecord::Migration[8.0]
  def change
    create_table :recipes do |t|
      t.string :title
      t.integer :cook_time
      t.integer :prep_time
      t.float :ratings
      t.string :cuisine
      t.string :category
      t.string :author
      t.string :image
      t.jsonb :ingredients_list

      t.timestamps
    end
  end
end
