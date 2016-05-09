class CreateSellers < ActiveRecord::Migration
  def change
    create_table :sellers do |t|
      t.string :short, unique: true, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :mobile

      t.timestamps null: false
    end
  end
end
