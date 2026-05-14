class CreatePicks < ActiveRecord::Migration[7.2]
  def change
    create_table :picks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :match, foreign_key: true
      t.references :knockout_match, foreign_key: true
      t.references :bracket_slot, foreign_key: true # which slot they picked the winner team for (knockout)
      t.references :team, foreign_key: true # team they picked to win (knockout)
      t.string :group_result # "home", "draw", "away" (group stage)
      t.integer :points_awarded, default: 0, null: false
      t.boolean :correct, default: false, null: false
      t.timestamps
    end
    add_index :picks, [:user_id, :match_id], unique: true, where: "match_id IS NOT NULL"
    add_index :picks, [:user_id, :knockout_match_id], unique: true, where: "knockout_match_id IS NOT NULL"
  end
end
