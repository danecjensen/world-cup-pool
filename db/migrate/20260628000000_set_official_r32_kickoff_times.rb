class SetOfficialR32KickoffTimes < ActiveRecord::Migration[7.2]
  # The R32 matches were seeded with a placeholder schedule (June 28 noon, then
  # every 6 hours by bracket position), so both the times and several dates were
  # wrong on the live site. This sets each match's real kickoff from the official
  # FIFA 2026 round-of-32 schedule, keyed on the stable official match number.
  #
  # Times below are Central Time (the app's default zone, CDT / UTC-5 in summer),
  # converted from the published local kickoffs. Times are stored as naive
  # wall-clock values built in the Central zone, matching how seeds.rb builds
  # every other kickoff_at.

  CENTRAL = "Central Time (US & Canada)".freeze

  # official match number => [year, month, day, hour, minute] in Central Time
  KICKOFFS = {
    73 => [2026, 6, 28, 14, 0],  # South Africa vs Canada
    76 => [2026, 6, 29, 12, 0],  # Brazil vs Japan
    74 => [2026, 6, 29, 15, 30], # Germany vs Paraguay
    75 => [2026, 6, 29, 20, 0],  # Netherlands vs Morocco
    78 => [2026, 6, 30, 12, 0],  # Ivory Coast vs Norway
    77 => [2026, 6, 30, 16, 0],  # France vs Sweden
    79 => [2026, 6, 30, 20, 0],  # Mexico vs Ecuador
    80 => [2026, 7,  1, 11, 0],  # England vs DR Congo
    82 => [2026, 7,  1, 15, 0],  # Belgium vs Senegal
    81 => [2026, 7,  1, 19, 0],  # United States vs Bosnia and Herzegovina
    84 => [2026, 7,  2, 14, 0],  # Spain vs Runner-up Group J
    83 => [2026, 7,  2, 18, 0],  # Portugal vs Croatia
    85 => [2026, 7,  2, 22, 0],  # Switzerland vs 3rd Group G/J
    88 => [2026, 7,  3, 13, 0],  # Australia vs Egypt
    86 => [2026, 7,  3, 17, 0],  # Argentina vs Cape Verde
    87 => [2026, 7,  3, 20, 30]  # Colombia vs Ghana
  }.freeze

  def up
    central = ActiveSupport::TimeZone[CENTRAL]
    match = Class.new(ActiveRecord::Base) { self.table_name = "knockout_matches" }
    KICKOFFS.each do |number, parts|
      match.where(number: number).update_all(kickoff_at: central.local(*parts))
    end
  end

  def down
    # Restore the original placeholder schedule (June 28 noon + 6h per slot).
    central = ActiveSupport::TimeZone[CENTRAL]
    match = Class.new(ActiveRecord::Base) { self.table_name = "knockout_matches" }
    base = central.local(2026, 6, 28, 12, 0)
    match.where(round: "r32").order(:bracket_position).each_with_index do |km, idx|
      match.where(id: km.id).update_all(kickoff_at: base + (idx * 6).hours)
    end
  end
end
