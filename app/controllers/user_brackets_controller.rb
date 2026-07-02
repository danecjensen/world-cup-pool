class UserBracketsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_knockout_access!

  # Read-only view of one player's knockout bracket, linked from the standings.
  def show
    @user = User.find(params[:user_id])

    # Same fairness gate as the insights page: another player's picks stay
    # hidden until brackets lock at first R32 kickoff. Your own bracket (and
    # admins) can always look.
    unless @user == current_user || knockout_stage_locked? || admin_user?
      redirect_to standings_path, alert: "Brackets are hidden until picks lock at the first R32 kickoff."
      return
    end

    @rounds = KnockoutMatch::ROUNDS
    @matches_by_round = KnockoutMatch.includes(:home_slot, :away_slot, :home_team, :away_team)
                                     .order(:bracket_position).group_by(&:round)
    @picks_by_km = @user.picks.where.not(knockout_match_id: nil).index_by(&:knockout_match_id)
  end

  private

  # Mirror the bracket gate: behind the feature flag, only admins may peek.
  def require_knockout_access!
    return if knockout_visible?

    redirect_to root_path, alert: "The knockout bracket isn't open yet — check back soon!"
  end
end
