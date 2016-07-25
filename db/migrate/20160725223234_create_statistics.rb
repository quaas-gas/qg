class CreateStatistics < ActiveRecord::Migration
  def change
    create_table :statistics do |t|
      t.string :name
      t.jsonb :time_range
      t.jsonb :grouping
      t.jsonb :filter
      t.string :sums_of

      t.timestamps null: false
    end
  end
end
