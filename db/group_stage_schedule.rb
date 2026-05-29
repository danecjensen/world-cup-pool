# Official 2026 FIFA World Cup group-stage fixtures.
# Kickoff times are Central Time; the Time.zone in callers converts to UTC.
GROUP_STAGE_SCHEDULE = [
  # Group A
  { group: "A", home: "MEX", away: "RSA", kickoff: [2026, 6, 11, 14,  0], venue: "Estadio Azteca, Mexico City" },
  { group: "A", home: "KOR", away: "CZE", kickoff: [2026, 6, 11, 21,  0], venue: "Estadio Akron, Zapopan" },
  { group: "A", home: "CZE", away: "RSA", kickoff: [2026, 6, 18, 11,  0], venue: "Mercedes-Benz Stadium, Atlanta" },
  { group: "A", home: "MEX", away: "KOR", kickoff: [2026, 6, 18, 20,  0], venue: "Estadio Akron, Zapopan" },
  { group: "A", home: "CZE", away: "MEX", kickoff: [2026, 6, 24, 20,  0], venue: "Estadio Azteca, Mexico City" },
  { group: "A", home: "RSA", away: "KOR", kickoff: [2026, 6, 24, 20,  0], venue: "Estadio BBVA, Guadalupe" },

  # Group B
  { group: "B", home: "CAN", away: "BIH", kickoff: [2026, 6, 12, 14,  0], venue: "BMO Field, Toronto" },
  { group: "B", home: "QAT", away: "SUI", kickoff: [2026, 6, 13, 14,  0], venue: "Levi's Stadium, Santa Clara" },
  { group: "B", home: "SUI", away: "BIH", kickoff: [2026, 6, 18, 14,  0], venue: "SoFi Stadium, Inglewood" },
  { group: "B", home: "CAN", away: "QAT", kickoff: [2026, 6, 18, 17,  0], venue: "BC Place, Vancouver" },
  { group: "B", home: "SUI", away: "CAN", kickoff: [2026, 6, 24, 14,  0], venue: "BC Place, Vancouver" },
  { group: "B", home: "BIH", away: "QAT", kickoff: [2026, 6, 24, 14,  0], venue: "Lumen Field, Seattle" },

  # Group C
  { group: "C", home: "BRA", away: "MAR", kickoff: [2026, 6, 13, 17,  0], venue: "MetLife Stadium, East Rutherford" },
  { group: "C", home: "HAI", away: "SCO", kickoff: [2026, 6, 13, 20,  0], venue: "Gillette Stadium, Foxborough" },
  { group: "C", home: "SCO", away: "MAR", kickoff: [2026, 6, 19, 17,  0], venue: "Gillette Stadium, Foxborough" },
  { group: "C", home: "BRA", away: "HAI", kickoff: [2026, 6, 19, 19, 30], venue: "Lincoln Financial Field, Philadelphia" },
  { group: "C", home: "SCO", away: "BRA", kickoff: [2026, 6, 24, 17,  0], venue: "Hard Rock Stadium, Miami Gardens" },
  { group: "C", home: "MAR", away: "HAI", kickoff: [2026, 6, 24, 17,  0], venue: "Mercedes-Benz Stadium, Atlanta" },

  # Group D
  { group: "D", home: "USA", away: "PAR", kickoff: [2026, 6, 12, 20,  0], venue: "SoFi Stadium, Inglewood" },
  { group: "D", home: "AUS", away: "TUR", kickoff: [2026, 6, 13, 23,  0], venue: "BC Place, Vancouver" },
  { group: "D", home: "USA", away: "AUS", kickoff: [2026, 6, 19, 14,  0], venue: "Lumen Field, Seattle" },
  { group: "D", home: "TUR", away: "PAR", kickoff: [2026, 6, 19, 22,  0], venue: "Levi's Stadium, Santa Clara" },
  { group: "D", home: "TUR", away: "USA", kickoff: [2026, 6, 25, 21,  0], venue: "SoFi Stadium, Inglewood" },
  { group: "D", home: "PAR", away: "AUS", kickoff: [2026, 6, 25, 21,  0], venue: "Levi's Stadium, Santa Clara" },

  # Group E
  { group: "E", home: "GER", away: "CUW", kickoff: [2026, 6, 14, 12,  0], venue: "NRG Stadium, Houston" },
  { group: "E", home: "CIV", away: "ECU", kickoff: [2026, 6, 14, 18,  0], venue: "Lincoln Financial Field, Philadelphia" },
  { group: "E", home: "GER", away: "CIV", kickoff: [2026, 6, 20, 15,  0], venue: "BMO Field, Toronto" },
  { group: "E", home: "ECU", away: "CUW", kickoff: [2026, 6, 20, 19,  0], venue: "Arrowhead Stadium, Kansas City" },
  { group: "E", home: "CUW", away: "CIV", kickoff: [2026, 6, 25, 15,  0], venue: "Lincoln Financial Field, Philadelphia" },
  { group: "E", home: "ECU", away: "GER", kickoff: [2026, 6, 25, 15,  0], venue: "MetLife Stadium, East Rutherford" },

  # Group F
  { group: "F", home: "NED", away: "JPN", kickoff: [2026, 6, 14, 15,  0], venue: "AT&T Stadium, Arlington" },
  { group: "F", home: "SWE", away: "TUN", kickoff: [2026, 6, 14, 21,  0], venue: "Estadio BBVA, Guadalupe" },
  { group: "F", home: "NED", away: "SWE", kickoff: [2026, 6, 20, 12,  0], venue: "NRG Stadium, Houston" },
  { group: "F", home: "TUN", away: "JPN", kickoff: [2026, 6, 20, 23,  0], venue: "Estadio BBVA, Guadalupe" },
  { group: "F", home: "JPN", away: "SWE", kickoff: [2026, 6, 25, 18,  0], venue: "AT&T Stadium, Arlington" },
  { group: "F", home: "TUN", away: "NED", kickoff: [2026, 6, 25, 18,  0], venue: "Arrowhead Stadium, Kansas City" },

  # Group G
  { group: "G", home: "BEL", away: "EGY", kickoff: [2026, 6, 15, 14,  0], venue: "Lumen Field, Seattle" },
  { group: "G", home: "IRN", away: "NZL", kickoff: [2026, 6, 15, 20,  0], venue: "SoFi Stadium, Inglewood" },
  { group: "G", home: "BEL", away: "IRN", kickoff: [2026, 6, 21, 14,  0], venue: "SoFi Stadium, Inglewood" },
  { group: "G", home: "NZL", away: "EGY", kickoff: [2026, 6, 21, 20,  0], venue: "BC Place, Vancouver" },
  { group: "G", home: "EGY", away: "IRN", kickoff: [2026, 6, 26, 22,  0], venue: "Lumen Field, Seattle" },
  { group: "G", home: "NZL", away: "BEL", kickoff: [2026, 6, 26, 22,  0], venue: "BC Place, Vancouver" },

  # Group H
  { group: "H", home: "ESP", away: "CPV", kickoff: [2026, 6, 15, 11,  0], venue: "Mercedes-Benz Stadium, Atlanta" },
  { group: "H", home: "KSA", away: "URU", kickoff: [2026, 6, 15, 17,  0], venue: "Hard Rock Stadium, Miami Gardens" },
  { group: "H", home: "ESP", away: "KSA", kickoff: [2026, 6, 21, 11,  0], venue: "Mercedes-Benz Stadium, Atlanta" },
  { group: "H", home: "URU", away: "CPV", kickoff: [2026, 6, 21, 17,  0], venue: "Hard Rock Stadium, Miami Gardens" },
  { group: "H", home: "CPV", away: "KSA", kickoff: [2026, 6, 26, 19,  0], venue: "NRG Stadium, Houston" },
  { group: "H", home: "URU", away: "ESP", kickoff: [2026, 6, 26, 19,  0], venue: "Estadio Akron, Zapopan" },

  # Group I
  { group: "I", home: "FRA", away: "SEN", kickoff: [2026, 6, 16, 14,  0], venue: "MetLife Stadium, East Rutherford" },
  { group: "I", home: "IRQ", away: "NOR", kickoff: [2026, 6, 16, 17,  0], venue: "Gillette Stadium, Foxborough" },
  { group: "I", home: "FRA", away: "IRQ", kickoff: [2026, 6, 22, 16,  0], venue: "Lincoln Financial Field, Philadelphia" },
  { group: "I", home: "NOR", away: "SEN", kickoff: [2026, 6, 22, 19,  0], venue: "MetLife Stadium, East Rutherford" },
  { group: "I", home: "NOR", away: "FRA", kickoff: [2026, 6, 26, 14,  0], venue: "Gillette Stadium, Foxborough" },
  { group: "I", home: "SEN", away: "IRQ", kickoff: [2026, 6, 26, 14,  0], venue: "BMO Field, Toronto" },

  # Group J
  { group: "J", home: "ARG", away: "ALG", kickoff: [2026, 6, 16, 20,  0], venue: "Arrowhead Stadium, Kansas City" },
  { group: "J", home: "AUT", away: "JOR", kickoff: [2026, 6, 16, 23,  0], venue: "Levi's Stadium, Santa Clara" },
  { group: "J", home: "ARG", away: "AUT", kickoff: [2026, 6, 22, 12,  0], venue: "AT&T Stadium, Arlington" },
  { group: "J", home: "JOR", away: "ALG", kickoff: [2026, 6, 22, 22,  0], venue: "Levi's Stadium, Santa Clara" },
  { group: "J", home: "ALG", away: "AUT", kickoff: [2026, 6, 27, 21,  0], venue: "Arrowhead Stadium, Kansas City" },
  { group: "J", home: "JOR", away: "ARG", kickoff: [2026, 6, 27, 21,  0], venue: "AT&T Stadium, Arlington" },

  # Group K
  { group: "K", home: "POR", away: "COD", kickoff: [2026, 6, 17, 12,  0], venue: "NRG Stadium, Houston" },
  { group: "K", home: "UZB", away: "COL", kickoff: [2026, 6, 17, 21,  0], venue: "Estadio Azteca, Mexico City" },
  { group: "K", home: "POR", away: "UZB", kickoff: [2026, 6, 23, 12,  0], venue: "NRG Stadium, Houston" },
  { group: "K", home: "COL", away: "COD", kickoff: [2026, 6, 23, 21,  0], venue: "Estadio Akron, Zapopan" },
  { group: "K", home: "COL", away: "POR", kickoff: [2026, 6, 27, 18, 30], venue: "Hard Rock Stadium, Miami Gardens" },
  { group: "K", home: "COD", away: "UZB", kickoff: [2026, 6, 27, 18, 30], venue: "Mercedes-Benz Stadium, Atlanta" },

  # Group L
  { group: "L", home: "ENG", away: "CRO", kickoff: [2026, 6, 17, 15,  0], venue: "AT&T Stadium, Arlington" },
  { group: "L", home: "GHA", away: "PAN", kickoff: [2026, 6, 17, 18,  0], venue: "BMO Field, Toronto" },
  { group: "L", home: "ENG", away: "GHA", kickoff: [2026, 6, 23, 15,  0], venue: "Gillette Stadium, Foxborough" },
  { group: "L", home: "PAN", away: "CRO", kickoff: [2026, 6, 23, 18,  0], venue: "BMO Field, Toronto" },
  { group: "L", home: "PAN", away: "ENG", kickoff: [2026, 6, 27, 16,  0], venue: "MetLife Stadium, East Rutherford" },
  { group: "L", home: "CRO", away: "GHA", kickoff: [2026, 6, 27, 16,  0], venue: "Lincoln Financial Field, Philadelphia" }
].freeze
