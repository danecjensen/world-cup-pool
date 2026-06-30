class ChampionPicksController < ApplicationController
  before_action :authenticate_user!
  before_action :require_knockout_access!

  # Every player's "winning it all" pick — the team they chose to win the Final —
  # grouped by team so you can see who's backing whom. Reached from the bracket
  # insights page.
  def show
    @champion_match = KnockoutMatch.find_by(round: "final")
    @total_users = User.count

    # Same fairness gate as the insights page: don't reveal who picked what until
    # bracket picks lock at first R32 kickoff (admins can always preview).
    @reveal = knockout_stage_locked? || admin_user?
    return unless @reveal && @champion_match

    picks = Pick.where(knockout_match_id: @champion_match.id)
                .where.not(team_id: nil)
                .includes(:user, :team)

    # team => [users] (alphabetical), ordered by how many players backed the team.
    @by_team = picks.group_by(&:team)
                    .transform_values { |ps| ps.map(&:user).sort_by { |u| u.display_name.to_s.downcase } }
                    .sort_by { |team, users| [-users.size, team.name] }

    picked_user_ids = picks.map(&:user_id).to_set
    @no_pick_users = User.where.not(id: picked_user_ids.to_a)
                         .order(Arel.sql("LOWER(display_name)"))
  end

  private

  # Mirror the bracket gate: behind the feature flag, only admins may peek.
  def require_knockout_access!
    return if knockout_visible?

    redirect_to root_path, alert: "The knockout bracket isn't open yet — check back soon!"
  end
end
