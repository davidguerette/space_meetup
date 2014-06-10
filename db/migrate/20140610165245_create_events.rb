class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.string :description
      t.string :location, null: false

      t.timestamp
    end
  end
end
