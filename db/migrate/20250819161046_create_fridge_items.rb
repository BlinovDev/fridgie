class CreateFridgeItems < ActiveRecord::Migration[8.0]
  def change
    create_table :fridge_items do |t|
      t.string :name
      t.references :fridge, null: false, foreign_key: true

      t.timestamps
    end
  end
end
