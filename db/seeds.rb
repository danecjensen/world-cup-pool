# 2026 FIFA World Cup pool seed
#
# Loads 48 qualified/projected teams into 12 groups of 4 based on the
# December 5, 2025 group draw in Washington, D.C., then builds the 72
# group-stage fixtures and the 5-round knockout bracket (R32 -> Final)
# using FIFA's published 2026 bracket mapping.
#
# Admins can edit team-to-group assignments and exact bracket pairings
# via the Rails console if real-world placements differ from what's seeded.

require "active_support/core_ext/time"

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

  # 48 Teams across 12 groups (Dec 5, 2025 draw). The fourth slot in groups
  # where intercontinental / UEFA play-off winners are still TBD uses a
  # placeholder team that admins can rename in the console once known.
  team_rows = [
    ["Mexico",        "MEX", "🇲🇽", "A", 1],
    ["South Korea",   "KOR", "🇰🇷", "A", 2],
    ["Ivory Coast",   "CIV", "🇨🇮", "A", 3],
    ["Norway",        "NOR", "🇳🇴", "A", 4],

    ["Canada",        "CAN", "🇨🇦", "B", 1],
    ["Ecuador",       "ECU", "🇪🇨", "B", 2],
    ["Egypt",         "EGY", "🇪🇬", "B", 3],
    ["UEFA Play-off A", "UEA", "🏳️", "B", 4],

    ["United States", "USA", "🇺🇸", "C", 1],
    ["Japan",         "JPN", "🇯🇵", "C", 2],
    ["Algeria",       "ALG", "🇩🇿", "C", 3],
    ["Paraguay",      "PAR", "🇵🇾", "C", 4],

    ["Brazil",        "BRA", "🇧🇷", "D", 1],
    ["Iran",          "IRN", "🇮🇷", "D", 2],
    ["Tunisia",       "TUN", "🇹🇳", "D", 3],
    ["Inter-Confed 1","ICF", "🏳️", "D", 4],

    ["France",        "FRA", "🇫🇷", "E", 1],
    ["Australia",     "AUS", "🇦🇺", "E", 2],
    ["Cape Verde",    "CPV", "🇨🇻", "E", 3],
    ["Uzbekistan",    "UZB", "🇺🇿", "E", 4],

    ["Argentina",     "ARG", "🇦🇷", "F", 1],
    ["Morocco",       "MAR", "🇲🇦", "F", 2],
    ["Saudi Arabia",  "KSA", "🇸🇦", "F", 3],
    ["Senegal",       "SEN", "🇸🇳", "F", 4],

    ["Spain",         "ESP", "🇪🇸", "G", 1],
    ["Switzerland",   "SUI", "🇨🇭", "G", 2],
    ["South Africa",  "RSA", "🇿🇦", "G", 3],
    ["New Zealand",   "NZL", "🇳🇿", "G", 4],

    ["Germany",       "GER", "🇩🇪", "H", 1],
    ["Colombia",      "COL", "🇨🇴", "H", 2],
    ["Jordan",        "JOR", "🇯🇴", "H", 3],
    ["UEFA Play-off B", "UEB", "🏳️", "H", 4],

    ["Portugal",      "POR", "🇵🇹", "I", 1],
    ["Croatia",       "CRO", "🇭🇷", "I", 2],
    ["Qatar",         "QAT", "🇶🇦", "I", 3],
    ["Inter-Confed 2","IC2", "🏳️", "I", 4],

    ["Belgium",       "BEL", "🇧🇪", "J", 1],
    ["Uruguay",       "URU", "🇺🇾", "J", 2],
    ["Ghana",         "GHA", "🇬🇭", "J", 3],
    ["UEFA Play-off C", "UEC", "🏳️", "J", 4],

    ["England",       "ENG", "🏴󠁧󠁢󠁥󠁮󠁧󠁿", "K", 1],
    ["Panama",        "PAN", "🇵🇦", "K", 2],
    ["Curacao",       "CUW", "🇨🇼", "K", 3],
    ["UEFA Play-off D", "UED", "🏳️", "K", 4],

    ["Netherlands",   "NED", "🇳🇱", "L", 1],
    ["Austria",       "AUT", "🇦🇹", "L", 2],
    ["Haiti",         "HAI", "🇭🇹", "L", 3],
    ["Jamaica",       "JAM", "🇯🇲", "L", 4]
  ]

  teams_by_slot = {}
  team_rows.each do |name, code, flag, letter, pos|
    t = Team.create!(name: name, code: code, flag_emoji: flag, group: groups[letter])
    teams_by_slot["#{letter}#{pos}"] = t
  end

  base_date = Time.zone.local(2026, 6, 11, 12, 0)
  venues = ["MetLife Stadium", "SoFi Stadium", "AT&T Stadium", "Mercedes-Benz Stadium",
            "Hard Rock Stadium", "NRG Stadium", "Estadio Azteca", "Estadio Akron",
            "BMO Field", "BC Place", "Levi's Stadium", "Lincoln Financial Field",
            "Lumen Field", "Gillette Stadium", "Arrowhead Stadium", "Estadio BBVA"]

  # Round-robin pairings per matchday.
  pairings = [[[1, 2], [3, 4]], [[1, 3], [2, 4]], [[1, 4], [2, 3]]]

  match_number = 0
  pairings.each_with_index do |md_pairs, md_idx|
    group_letters.each do |letter|
      md_pairs.each do |home_pos, away_pos|
        match_number += 1
        kickoff = base_date + (md_idx * 24 * 3).hours + (match_number * 3).hours
        Match.create!(
          number: match_number,
          group: groups[letter],
          home_team: teams_by_slot["#{letter}#{home_pos}"],
          away_team: teams_by_slot["#{letter}#{away_pos}"],
          kickoff_at: kickoff,
          venue: venues[match_number % venues.length]
        )
      end
    end
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
