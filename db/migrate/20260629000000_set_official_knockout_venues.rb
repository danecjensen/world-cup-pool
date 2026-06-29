class SetOfficialKnockoutVenues < ActiveRecord::Migration[7.2]
  # The knockout matches were seeded with placeholder venues (a round-robin over
  # the stadium list by bracket position), so the venue shown for each knockout
  # match on the live site was wrong. This sets each match's real venue from the
  # official FIFA 2026 schedule, keyed on the stable official match number (the
  # same key used by SetOfficialR32KickoffTimes). Venues use the same
  # "Stadium, City" format as the group-stage schedule.
  #
  # Venues verified against the FIFA 2026 schedule and Wikipedia's
  # "2026 FIFA World Cup knockout stage" article.

  # official match number => venue
  VENUES = {
    # Round of 32
    73 => "SoFi Stadium, Inglewood",
    74 => "Gillette Stadium, Foxborough",
    75 => "Estadio BBVA, Guadalupe",
    76 => "NRG Stadium, Houston",
    77 => "MetLife Stadium, East Rutherford",
    78 => "AT&T Stadium, Arlington",
    79 => "Estadio Azteca, Mexico City",
    80 => "Mercedes-Benz Stadium, Atlanta",
    81 => "Levi's Stadium, Santa Clara",
    82 => "Lumen Field, Seattle",
    83 => "BMO Field, Toronto",
    84 => "SoFi Stadium, Inglewood",
    85 => "BC Place, Vancouver",
    86 => "Hard Rock Stadium, Miami Gardens",
    87 => "Arrowhead Stadium, Kansas City",
    88 => "AT&T Stadium, Arlington",
    # Round of 16
    89 => "Lincoln Financial Field, Philadelphia",
    90 => "NRG Stadium, Houston",
    91 => "MetLife Stadium, East Rutherford",
    92 => "Estadio Azteca, Mexico City",
    93 => "AT&T Stadium, Arlington",
    94 => "Lumen Field, Seattle",
    95 => "Mercedes-Benz Stadium, Atlanta",
    96 => "BC Place, Vancouver",
    # Quarter-finals
    97 => "Gillette Stadium, Foxborough",
    98 => "SoFi Stadium, Inglewood",
    99 => "Hard Rock Stadium, Miami Gardens",
    100 => "Arrowhead Stadium, Kansas City",
    # Semi-finals
    101 => "AT&T Stadium, Arlington",
    102 => "Mercedes-Benz Stadium, Atlanta",
    # Final
    104 => "MetLife Stadium, East Rutherford"
  }.freeze

  def up
    match = Class.new(ActiveRecord::Base) { self.table_name = "knockout_matches" }
    VENUES.each do |number, venue|
      match.where(number: number).update_all(venue: venue)
    end
  end

  def down
    # Restore the original placeholder venues (round-robin over the stadium list
    # by bracket position within each round, matching the pre-fix seeds.rb).
    venues = ["MetLife Stadium", "SoFi Stadium", "AT&T Stadium", "Mercedes-Benz Stadium",
              "Hard Rock Stadium", "NRG Stadium", "Estadio Azteca", "Estadio Akron",
              "BMO Field", "BC Place", "Levi's Stadium", "Lincoln Financial Field",
              "Lumen Field", "Gillette Stadium", "Arrowhead Stadium", "Estadio BBVA"]
    match = Class.new(ActiveRecord::Base) { self.table_name = "knockout_matches" }
    %w[r32 r16 qf sf final].each do |round|
      match.where(round: round).order(:bracket_position).each_with_index do |km, idx|
        match.where(id: km.id).update_all(venue: venues[idx % venues.length])
      end
    end
  end
end
