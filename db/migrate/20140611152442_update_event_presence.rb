class UpdateEventPresence < ActiveRecord::Migration
  def up
    change_column(:events, :description, :text, null: false)
  end

  def down
    change_column(:events, :description, :string, null: true)
  end
end
