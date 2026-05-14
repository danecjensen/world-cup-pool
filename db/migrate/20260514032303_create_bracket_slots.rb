class CreateBracketSlots < ActiveRecord::Migration[7.2]
  def change
    create_table :bracket_slots do |t|
      t.string :code, null: false # e.g. "1A", "2B", "3CDEF", or "W49"
      t.string :source_type, null: false # "group_position" or "match_winner"
      t.string :group_letter
      t.integer :position # 1, 2, 3 (for group finishers)
      t.bigint :source_match_id # for match_winner
      t.references :team, foreign_key: true # resolved team
      t.timestamps
    end
    add_index :bracket_slots, :code, unique: true
  end
end
