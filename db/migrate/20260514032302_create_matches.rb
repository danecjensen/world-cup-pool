class CreateMatches < ActiveRecord::Migration[7.2]
  def change
    create_table :matches do |t|
      t.integer :number, null: false
      t.references :group, foreign_key: true
      t.references :home_team, foreign_key: { to_table: :teams }
      t.references :away_team, foreign_key: { to_table: :teams }
      t.datetime :kickoff_at, null: false
      t.string :venue
      t.integer :home_score
      t.integer :away_score
      t.string :result # "home", "away", "draw"
      t.timestamps
    end
    add_index :matches, :number, unique: true
  end
end
