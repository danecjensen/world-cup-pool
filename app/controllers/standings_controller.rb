class StandingsController < ApplicationController
  def index
    select_sql = <<~SQL
      users.*,
      COALESCE(SUM(picks.points_awarded), 0) AS total_points,
      COALESCE(SUM(CASE WHEN picks.correct THEN 1 ELSE 0 END), 0) AS correct_picks,
      COALESCE(SUM(CASE WHEN picks.match_id IS NOT NULL AND picks.correct THEN 1 ELSE 0 END), 0) AS group_correct,
      COALESCE(SUM(CASE WHEN picks.knockout_match_id IS NOT NULL AND picks.correct THEN 1 ELSE 0 END), 0) AS bracket_correct
    SQL

    @players = User.left_joins(:picks)
                   .group("users.id")
                   .select(select_sql)
                   .order(Arel.sql("total_points DESC, users.display_name ASC"))
  end
end
