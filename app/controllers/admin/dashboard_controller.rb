class Admin::DashboardController < Admin::BaseController
  def index
    @group_match_count = Match.count
    @group_finished = Match.where.not(result: nil).count
    @knockout_count = KnockoutMatch.count
    @knockout_finished = KnockoutMatch.where.not(winner_team_id: nil).count
    @user_count = User.count
    @pending_bracket_slots = BracketSlot.where(team_id: nil).count
    @pending_post_count = Post.pending.count
  end

  def recompute_scores
    ScoringService.recompute_all
    redirect_to admin_root_path, notice: "Scores recomputed."
  end

  def toggle_bracket_visibility
    setting = SiteSetting.current
    setting.update!(bracket_visible: !setting.bracket_visible?)
    redirect_to admin_root_path,
                notice: "Bracket is now #{setting.bracket_visible? ? 'visible' : 'hidden'} to users."
  end
end
