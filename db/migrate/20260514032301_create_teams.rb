class CreateTeams < ActiveRecord::Migration[7.2]
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.string :flag_emoji
      t.references :group, foreign_key: true
      t.timestamps
    end
    add_index :teams, :code, unique: true
    add_index :teams, :name, unique: true
  end
end
