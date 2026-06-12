class HomeController < ApplicationController
  def index
    @user_count = User.count
    @recent_posts = Post.includes(:user, :comments, media_attachment: :blob).newest_first.limit(3)
    @first_kickoff_at = Match.minimum(:kickoff_at)
    @team_flags = Team.joins(:group).order("groups.letter", "teams.id").pluck(:flag_emoji, :name)
    @next_match = Match.where("kickoff_at > ?", Time.current).order(:kickoff_at).first
    @next_knockout = KnockoutMatch.where("kickoff_at > ?", Time.current).order(:kickoff_at).first
    if user_signed_in?
      @next_match_pick = @next_match && current_user.picks.find_by(match_id: @next_match.id)
      @next_knockout_pick = @next_knockout && current_user.picks.find_by(knockout_match_id: @next_knockout.id)
    end
    @top_players = User.left_joins(:picks)
                       .group("users.id")
                       .select("users.*, COALESCE(SUM(picks.points_awarded), 0) AS total")
                       .order("total DESC")
                       .limit(5)
  end
end
