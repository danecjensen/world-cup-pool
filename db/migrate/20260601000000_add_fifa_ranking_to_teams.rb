class AddFifaRankingToTeams < ActiveRecord::Migration[7.2]
  # FIFA/Coca-Cola Men's World Ranking as of the April 1, 2026 release.
  RANKINGS = {
    "MEX" => 15, "KOR" => 25, "RSA" => 60, "CZE" => 41,
    "CAN" => 30, "SUI" => 19, "QAT" => 55, "BIH" => 65,
    "BRA" => 6,  "MAR" => 8,  "SCO" => 43, "HAI" => 83,
    "USA" => 16, "AUS" => 27, "PAR" => 40, "TUR" => 22,
    "GER" => 10, "ECU" => 23, "CIV" => 34, "CUW" => 82,
    "NED" => 7,  "JPN" => 18, "TUN" => 44, "SWE" => 38,
    "BEL" => 9,  "IRN" => 21, "EGY" => 29, "NZL" => 85,
    "ESP" => 2,  "URU" => 17, "KSA" => 61, "CPV" => 69,
    "FRA" => 1,  "SEN" => 14, "NOR" => 31, "IRQ" => 57,
    "ARG" => 3,  "AUT" => 24, "ALG" => 28, "JOR" => 63,
    "POR" => 5,  "COL" => 13, "UZB" => 50, "COD" => 46,
    "ENG" => 4,  "CRO" => 11, "PAN" => 33, "GHA" => 74
  }.freeze

  def up
    add_column :teams, :fifa_ranking, :integer

    RANKINGS.each do |code, rank|
      execute(<<~SQL.squish)
        UPDATE teams SET fifa_ranking = #{rank.to_i} WHERE code = #{ActiveRecord::Base.connection.quote(code)}
      SQL
    end
  end

  def down
    remove_column :teams, :fifa_ranking
  end
end
