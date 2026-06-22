class CreateWatchParties < ActiveRecord::Migration[7.2]
  def change
    create_table :watch_parties do |t|
      t.references :user, null: false, foreign_key: true
      t.references :match, null: true, foreign_key: true
      t.string :location, null: false
      t.string :match_label

      t.timestamps
    end

    add_index :watch_parties, :created_at
  end
end
