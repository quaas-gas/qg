class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|
      t.references :customer, index: true, foreign_key: true
      t.references :bottle, index: true, foreign_key: true
      t.date :valid_from
      t.monetize :price
      t.monetize :discount

      t.timestamps null: false
    end
  end
end
