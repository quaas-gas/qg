class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :name
      t.jsonb :product_categories
      t.jsonb :content_product_categories
      t.jsonb :products
      t.boolean :in_menu

      t.timestamps null: false
    end
  end
end
