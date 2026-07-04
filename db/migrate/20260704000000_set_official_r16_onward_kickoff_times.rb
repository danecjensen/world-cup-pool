class SetOfficialR16OnwardKickoffTimes < ActiveRecord::Migration[7.2]
  # The R16, quarter-final, semi-final, and final matches were seeded with a
  # placeholder schedule (a fixed base time plus a fixed step per bracket
  # position), so the "Next up" section showed wrong dates and times once the
  # round of 16 began — e.g. Paraguay vs France at 7:00 AM and Portugal vs
  # Spain on July 4 instead of July 6. This sets each match's real kickoff
  # from the official FIFA 2026 schedule, keyed on the stable official match
  # number, exactly like SetOfficialR32KickoffTimes did for the round of 32.
  #
  # Times below are Central Time (the app's default zone, CDT / UTC-5 in
  # summer), converted from the published Eastern Time kickoffs.

  CENTRAL = "Central Time (US & Canada)".freeze

  # official match number => [year, month, day, hour, minute] in Central Time
  KICKOFFS = {
    # Round of 16
    90 => [2026, 7,  4, 12, 0],  # Canada vs Morocco, Houston
    89 => [2026, 7,  4, 16, 0],  # Paraguay vs France, Philadelphia
    91 => [2026, 7,  5, 15, 0],  # Brazil vs Norway, East Rutherford
    92 => [2026, 7,  5, 19, 0],  # Mexico vs England, Mexico City
    93 => [2026, 7,  6, 14, 0],  # Portugal vs Spain, Arlington
    94 => [2026, 7,  6, 19, 0],  # United States vs Belgium, Seattle
    95 => [2026, 7,  7, 11, 0],  # Argentina vs Egypt, Atlanta
    96 => [2026, 7,  7, 15, 0],  # Switzerland vs Colombia/Ghana, Vancouver
    # Quarter-finals
    97 => [2026, 7,  9, 15, 0],  # Foxborough
    98 => [2026, 7, 10, 14, 0],  # Inglewood
    99 => [2026, 7, 11, 16, 0],  # Miami Gardens
    100 => [2026, 7, 11, 20, 0], # Kansas City
    # Semi-finals
    101 => [2026, 7, 14, 14, 0], # Arlington
    102 => [2026, 7, 15, 14, 0], # Atlanta
    # Final
    104 => [2026, 7, 19, 14, 0]  # East Rutherford
  }.freeze

  def up
    central = ActiveSupport::TimeZone[CENTRAL]
    match = Class.new(ActiveRecord::Base) { self.table_name = "knockout_matches" }
    KICKOFFS.each do |number, parts|
      match.where(number: number).update_all(kickoff_at: central.local(*parts))
    end
  end

  def down
    # Restore the original placeholder schedule (base time + step per slot).
    central = ActiveSupport::TimeZone[CENTRAL]
    match = Class.new(ActiveRecord::Base) { self.table_name = "knockout_matches" }
    placeholders = {
      "r16"   => [central.local(2026, 7, 4, 12, 0), 6],
      "qf"    => [central.local(2026, 7, 9, 14, 0), 6],
      "sf"    => [central.local(2026, 7, 14, 18, 0), 24],
      "final" => [central.local(2026, 7, 19, 15, 0), 0]
    }
    placeholders.each do |round, (base, step_hours)|
      match.where(round: round).order(:bracket_position).each_with_index do |km, idx|
        match.where(id: km.id).update_all(kickoff_at: base + (idx * step_hours).hours)
      end
    end
  end
end
