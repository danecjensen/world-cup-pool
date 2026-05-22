class CreateGroups < ActiveRecord::Migration[7.2]
  def change
    create_table :groups do |t|
      t.string :letter, null: false
      t.timestamps
    end
    add_index :groups, :letter, unique: true
  end
end
