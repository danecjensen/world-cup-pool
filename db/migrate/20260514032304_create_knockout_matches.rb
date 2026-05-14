class CreateKnockoutMatches < ActiveRecord::Migration[7.2]
  def change
    create_table :knockout_matches do |t|
      t.integer :number, null: false # global match number (73..104)
      t.string :round, null: false # "r32", "r16", "qf", "sf", "final"
      t.integer :bracket_position, null: false # ordering within round
      t.references :home_slot, foreign_key: { to_table: :bracket_slots }
      t.references :away_slot, foreign_key: { to_table: :bracket_slots }
      t.references :winner_slot, foreign_key: { to_table: :bracket_slots } # slot this match feeds into
      t.references :home_team, foreign_key: { to_table: :teams }
      t.references :away_team, foreign_key: { to_table: :teams }
      t.references :winner_team, foreign_key: { to_table: :teams }
      t.datetime :kickoff_at
      t.string :venue
      t.integer :home_score
      t.integer :away_score
      t.timestamps
    end
    add_index :knockout_matches, :number, unique: true
    add_index :knockout_matches, [:round, :bracket_position], unique: true
  end
end
