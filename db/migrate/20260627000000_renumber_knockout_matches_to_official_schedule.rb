class RenumberKnockoutMatchesToOfficialSchedule < ActiveRecord::Migration[7.2]
  # The knockout bracket originally numbered matches sequentially by their
  # visual bracket position (top R32 slot = 73, next = 74, ...). The official
  # FIFA 2026 schedule numbers matches by kickoff order instead, which is NOT
  # the same as bracket order — e.g. the top R32 slot is match 74, while the
  # earliest game (match 73) sits in the third slot. Because the bracket's
  # "Winner Match N" labels are driven by these numbers, the old scheme paired
  # the wrong matches (R16 slot 1 read "Winner 73 / 74" instead of "74 / 77").
  #
  # This rewrites each match's number — keyed on the stable
  # (round, bracket_position) — to the official number and keeps each match's
  # winner slot (source_match_id + code) in sync so the feeder labels follow.
  # Team assignments, picks and scores are untouched: they reference records by
  # id, never by match number.

  # bracket_position (1-based; index in the array) => official match number.
  OFFICIAL = {
    "r32"   => [74, 77, 73, 75, 83, 84, 81, 82, 76, 78, 79, 80, 86, 88, 85, 87],
    "r16"   => [89, 90, 93, 94, 91, 92, 95, 96],
    "qf"    => [97, 98, 99, 100],
    "sf"    => [101, 102],
    "final" => [104]
  }.freeze

  # The original sequential-by-position numbering, restored on rollback.
  SEQUENTIAL = {
    "r32"   => (73..88).to_a,
    "r16"   => (89..96).to_a,
    "qf"    => (97..100).to_a,
    "sf"    => (101..102).to_a,
    "final" => [103]
  }.freeze

  def up
    apply_numbering(OFFICIAL)
  end

  def down
    apply_numbering(SEQUENTIAL)
  end

  private

  def apply_numbering(scheme)
    # Self-contained AR classes so the migration never depends on app models.
    match = Class.new(ActiveRecord::Base) { self.table_name = "knockout_matches" }
    slot  = Class.new(ActiveRecord::Base) { self.table_name = "bracket_slots" }
    return if match.count.zero? # fresh database — seeds build it correctly

    match.transaction do
      # Park every number and winner-slot code out of the target range first so
      # the unique indexes never clash while values shuffle into new positions.
      match.where("number < 1000").update_all("number = number + 1000")
      slot.where(source_type: "match_winner").find_each do |s|
        s.update_columns(code: "TMP-#{s.id}")
      end

      scheme.each do |round, numbers|
        numbers.each_with_index do |number, idx|
          km = match.find_by(round: round, bracket_position: idx + 1)
          next unless km

          km.update_columns(number: number)
          next unless km.winner_slot_id

          slot.where(id: km.winner_slot_id)
              .update_all(source_match_id: number, code: "W#{number}")
        end
      end
    end
  end
end
