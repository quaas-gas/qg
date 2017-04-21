class AddGroupToProducts < ActiveRecord::Migration
  def change
    change_table :products do |t|
      t.string :group, index: true
    end
  end
end
