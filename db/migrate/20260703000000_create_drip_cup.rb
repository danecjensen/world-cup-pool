class CreateDripCup < ActiveRecord::Migration[7.2]
  def change
    add_column :site_settings, :drip_cup_enabled, :boolean, null: false, default: false

    create_table :kits do |t|
      t.string :name, null: false
      t.string :image_path, null: false
      t.float :rating, null: false, default: 1000.0
      t.integer :wins, null: false, default: 0
      t.integer :losses, null: false, default: 0
      t.timestamps
      t.index :image_path, unique: true
      t.index :rating
    end

    create_table :kit_votes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :winner_kit, null: false, foreign_key: { to_table: :kits }
      t.references :loser_kit, null: false, foreign_key: { to_table: :kits }
      t.timestamps
    end
  end
end
