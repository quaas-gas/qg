class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :number, unique: true
      t.string :name
      t.string :size
      t.string :content
      t.monetize :price
      t.jsonb :others

      t.timestamps null: false
    end
  end
end
