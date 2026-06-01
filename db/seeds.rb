# 2026 FIFA World Cup pool seed
#
# Loads the final 48 qualified teams into the 12 groups drawn on
# December 5, 2025 in Washington, D.C. All UEFA play-off paths
# (A: Bosnia & Herzegovina, B: Sweden, C: Turkey, D: Czechia) and
# inter-confederation play-off paths (1: DR Congo, 2: Iraq) are resolved
# with their March 2026 winners — there are no placeholder teams.
#
# Within each group, teams are listed in FIFA seeding-pot order
# (Pot 1 -> Pot 4). The intra-group position only affects the order group
# fixtures are displayed; bracket scoring uses final group standings.
#
# Then builds the 72 group-stage fixtures and the 5-round knockout bracket
# (R32 -> Final). Admins can adjust kickoff times/venues per match to match
# FIFA's published schedule.

require "active_support/core_ext/time"
require Rails.root.join("db/group_stage_schedule")

ActiveRecord::Base.transaction do
  if Team.exists? && ENV["FORCE_RESEED"] != "true"
    puts "Teams already seeded — skipping. Set FORCE_RESEED=true to wipe and reload."
    if ENV["ADMIN_EMAIL"].present? && ENV["ADMIN_PASSWORD"].present?
      User.find_or_create_by!(email: ENV["ADMIN_EMAIL"]) do |u|
        u.display_name = ENV.fetch("ADMIN_DISPLAY_NAME", "Commissioner")
        u.password = ENV["ADMIN_PASSWORD"]
        u.admin = true
      end
      puts "Ensured admin user #{ENV['ADMIN_EMAIL']}."
    end
    next
  end

  Pick.delete_all
  KnockoutMatch.delete_all
  BracketSlot.delete_all
  Match.delete_all
  Team.delete_all
  Group.delete_all

  group_letters = ("A".."L").to_a
  groups = group_letters.each_with_object({}) do |letter, h|
    h[letter] = Group.create!(letter: letter)
  end

  # Final 48 teams, grouped per the Dec 5, 2025 draw and resolved with the
  # March 2026 play-off winners. FIFA ranking is the April 1, 2026 release.
  # Format: [name, FIFA code, flag, group, pos, fifa_ranking].
  team_rows = [
    # Group A
    ["Mexico",                "MEX", "🇲🇽", "A", 1, 15],
    ["South Korea",           "KOR", "🇰🇷", "A", 2, 25],
    ["South Africa",          "RSA", "🇿🇦", "A", 3, 60],
    ["Czechia",               "CZE", "🇨🇿", "A", 4, 41],

    # Group B
    ["Canada",                "CAN", "🇨🇦", "B", 1, 30],
    ["Switzerland",           "SUI", "🇨🇭", "B", 2, 19],
    ["Qatar",                 "QAT", "🇶🇦", "B", 3, 55],
    ["Bosnia and Herzegovina", "BIH", "🇧🇦", "B", 4, 65],

    # Group C
    ["Brazil",                "BRA", "🇧🇷", "C", 1, 6],
    ["Morocco",               "MAR", "🇲🇦", "C", 2, 8],
    ["Scotland",              "SCO", "🏴󠁧󠁢󠁳󠁣󠁴󠁿", "C", 3, 43],
    ["Haiti",                 "HAI", "🇭🇹", "C", 4, 83],

    # Group D
    ["United States",         "USA", "🇺🇸", "D", 1, 16],
    ["Australia",             "AUS", "🇦🇺", "D", 2, 27],
    ["Paraguay",              "PAR", "🇵🇾", "D", 3, 40],
    ["Turkey",                "TUR", "🇹🇷", "D", 4, 22],

    # Group E
    ["Germany",               "GER", "🇩🇪", "E", 1, 10],
    ["Ecuador",               "ECU", "🇪🇨", "E", 2, 23],
    ["Ivory Coast",           "CIV", "🇨🇮", "E", 3, 34],
    ["Curaçao",               "CUW", "🇨🇼", "E", 4, 82],

    # Group F
    ["Netherlands",           "NED", "🇳🇱", "F", 1, 7],
    ["Japan",                 "JPN", "🇯🇵", "F", 2, 18],
    ["Tunisia",               "TUN", "🇹🇳", "F", 3, 44],
    ["Sweden",                "SWE", "🇸🇪", "F", 4, 38],

    # Group G
    ["Belgium",               "BEL", "🇧🇪", "G", 1, 9],
    ["Iran",                  "IRN", "🇮🇷", "G", 2, 21],
    ["Egypt",                 "EGY", "🇪🇬", "G", 3, 29],
    ["New Zealand",           "NZL", "🇳🇿", "G", 4, 85],

    # Group H
    ["Spain",                 "ESP", "🇪🇸", "H", 1, 2],
    ["Uruguay",               "URU", "🇺🇾", "H", 2, 17],
    ["Saudi Arabia",          "KSA", "🇸🇦", "H", 3, 61],
    ["Cape Verde",            "CPV", "🇨🇻", "H", 4, 69],

    # Group I
    ["France",                "FRA", "🇫🇷", "I", 1, 1],
    ["Senegal",               "SEN", "🇸🇳", "I", 2, 14],
    ["Norway",                "NOR", "🇳🇴", "I", 3, 31],
    ["Iraq",                  "IRQ", "🇮🇶", "I", 4, 57],

    # Group J
    ["Argentina",             "ARG", "🇦🇷", "J", 1, 3],
    ["Austria",               "AUT", "🇦🇹", "J", 2, 24],
    ["Algeria",               "ALG", "🇩🇿", "J", 3, 28],
    ["Jordan",                "JOR", "🇯🇴", "J", 4, 63],

    # Group K
    ["Portugal",              "POR", "🇵🇹", "K", 1, 5],
    ["Colombia",              "COL", "🇨🇴", "K", 2, 13],
    ["Uzbekistan",            "UZB", "🇺🇿", "K", 3, 50],
    ["DR Congo",              "COD", "🇨🇩", "K", 4, 46],

    # Group L
    ["England",               "ENG", "🏴󠁧󠁢󠁥󠁮󠁧󠁿", "L", 1, 4],
    ["Croatia",               "CRO", "🇭🇷", "L", 2, 11],
    ["Panama",                "PAN", "🇵🇦", "L", 3, 33],
    ["Ghana",                 "GHA", "🇬🇭", "L", 4, 74]
  ]

  teams_by_slot = {}
  team_rows.each do |name, code, flag, letter, pos, fifa_ranking|
    t = Team.create!(name: name, code: code, flag_emoji: flag, group: groups[letter], fifa_ranking: fifa_ranking)
    teams_by_slot["#{letter}#{pos}"] = t
  end

  central = ActiveSupport::TimeZone["Central Time (US & Canada)"]
  teams_by_code = Team.all.index_by(&:code)
  venues = ["MetLife Stadium", "SoFi Stadium", "AT&T Stadium", "Mercedes-Benz Stadium",
            "Hard Rock Stadium", "NRG Stadium", "Estadio Azteca", "Estadio Akron",
            "BMO Field", "BC Place", "Levi's Stadium", "Lincoln Financial Field",
            "Lumen Field", "Gillette Stadium", "Arrowhead Stadium", "Estadio BBVA"]

  GROUP_STAGE_SCHEDULE
    .map { |row| row.merge(kickoff_at: central.local(*row[:kickoff])) }
    .sort_by { |row| [row[:kickoff_at], row[:group]] }
    .each_with_index do |row, idx|
      Match.create!(
        number:     idx + 1,
        group:      groups[row[:group]],
        home_team:  teams_by_code.fetch(row[:home]),
        away_team:  teams_by_code.fetch(row[:away]),
        kickoff_at: row[:kickoff_at],
        venue:      row[:venue]
      )
    end

  # Bracket slots for group finishers (1st/2nd/3rd of each group, 36 total).
  group_letters.each do |letter|
    (1..3).each do |pos|
      BracketSlot.create!(
        code: "#{pos}#{letter}",
        source_type: "group_position",
        group_letter: letter,
        position: pos
      )
    end
  end

  # R32 pairings (32 teams -> 16 matches). The 8 best third-placed teams
  # join the 24 top-two finishers; FIFA matches them against group winners.
  # The exact 3rd-place permutation depends on which 8 of 12 thirds qualify,
  # so 4 pairings below use a representative "1X vs 3Y" pattern that the
  # admin can re-map post-group-stage.
  r32_pairs = [
    ["1A", "2B"], ["1C", "2D"], ["1E", "2F"], ["1G", "2H"],
    ["1I", "2J"], ["1K", "2L"], ["2A", "1B"], ["2C", "1D"],
    ["2E", "1F"], ["2G", "1H"], ["2I", "1J"], ["2K", "1L"],
    ["1A", "3C"], ["1B", "3D"], ["1H", "3E"], ["1L", "3I"]
  ]

  next_num = 73
  r32_pairs.each_with_index do |(home_code, away_code), idx|
    home_slot = BracketSlot.find_by(code: home_code)
    away_slot = BracketSlot.find_by(code: away_code)
    winner_slot = BracketSlot.create!(
      code: "W#{next_num}",
      source_type: "match_winner",
      source_match_id: next_num
    )
    KnockoutMatch.create!(
      number: next_num,
      round: "r32",
      bracket_position: idx + 1,
      home_slot: home_slot,
      away_slot: away_slot,
      winner_slot: winner_slot,
      kickoff_at: Time.zone.local(2026, 6, 28, 12, 0) + (idx * 6).hours,
      venue: venues[idx % venues.length]
    )
    next_num += 1
  end

  # R16: 8 matches, each pairs the winners of two consecutive R32 matches.
  8.times do |i|
    home_slot = BracketSlot.find_by(code: "W#{73 + i * 2}")
    away_slot = BracketSlot.find_by(code: "W#{73 + i * 2 + 1}")
    winner_slot = BracketSlot.create!(
      code: "W#{next_num}",
      source_type: "match_winner",
      source_match_id: next_num
    )
    KnockoutMatch.create!(
      number: next_num,
      round: "r16",
      bracket_position: i + 1,
      home_slot: home_slot,
      away_slot: away_slot,
      winner_slot: winner_slot,
      kickoff_at: Time.zone.local(2026, 7, 4, 12, 0) + (i * 6).hours,
      venue: venues[i % venues.length]
    )
    next_num += 1
  end

  # QF: 4 matches.
  4.times do |i|
    home_slot = BracketSlot.find_by(code: "W#{89 + i * 2}")
    away_slot = BracketSlot.find_by(code: "W#{89 + i * 2 + 1}")
    winner_slot = BracketSlot.create!(
      code: "W#{next_num}",
      source_type: "match_winner",
      source_match_id: next_num
    )
    KnockoutMatch.create!(
      number: next_num,
      round: "qf",
      bracket_position: i + 1,
      home_slot: home_slot,
      away_slot: away_slot,
      winner_slot: winner_slot,
      kickoff_at: Time.zone.local(2026, 7, 9, 14, 0) + (i * 6).hours,
      venue: venues[i % venues.length]
    )
    next_num += 1
  end

  # SF: 2 matches.
  2.times do |i|
    home_slot = BracketSlot.find_by(code: "W#{97 + i * 2}")
    away_slot = BracketSlot.find_by(code: "W#{97 + i * 2 + 1}")
    winner_slot = BracketSlot.create!(
      code: "W#{next_num}",
      source_type: "match_winner",
      source_match_id: next_num
    )
    KnockoutMatch.create!(
      number: next_num,
      round: "sf",
      bracket_position: i + 1,
      home_slot: home_slot,
      away_slot: away_slot,
      winner_slot: winner_slot,
      kickoff_at: Time.zone.local(2026, 7, 14, 18, 0) + (i * 24).hours,
      venue: venues[i % venues.length]
    )
    next_num += 1
  end

  # Final: 1 match — no further winner slot.
  KnockoutMatch.create!(
    number: next_num,
    round: "final",
    bracket_position: 1,
    home_slot: BracketSlot.find_by(code: "W101"),
    away_slot: BracketSlot.find_by(code: "W102"),
    kickoff_at: Time.zone.local(2026, 7, 19, 15, 0),
    venue: "MetLife Stadium"
  )

  if ENV["ADMIN_EMAIL"].present? && ENV["ADMIN_PASSWORD"].present?
    User.find_or_create_by!(email: ENV["ADMIN_EMAIL"]) do |u|
      u.display_name = ENV.fetch("ADMIN_DISPLAY_NAME", "Commissioner")
      u.password = ENV["ADMIN_PASSWORD"]
      u.admin = true
    end
  end

  puts "Seeded #{Group.count} groups, #{Team.count} teams, #{Match.count} group matches, " \
       "#{KnockoutMatch.count} knockout matches, #{BracketSlot.count} bracket slots."
end
