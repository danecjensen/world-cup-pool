class HomeController < ApplicationController
  def index
    @user_count = User.count
    @next_match = Match.where("kickoff_at > ?", Time.current).order(:kickoff_at).first
    @next_knockout = KnockoutMatch.where("kickoff_at > ?", Time.current).order(:kickoff_at).first
    @top_players = User.left_joins(:picks)
                       .group("users.id")
                       .select("users.*, COALESCE(SUM(picks.points_awarded), 0) AS total")
                       .order("total DESC")
                       .limit(5)
  end
end
