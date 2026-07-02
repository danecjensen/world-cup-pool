# Oversight page for picks entered on a player's behalf from the admin portal.
# Admin edits can swing the standings, so every admin-entered pick is listed
# here for the other admins (and the pool) to review.
class Admin::PickAuditsController < Admin::BaseController
  def index
    @picks = Pick.admin_entered
                 .includes(:user, :team,
                           match: [:home_team, :away_team],
                           knockout_match: [:home_team, :away_team, :home_slot, :away_slot])
                 .order(updated_at: :desc)
  end
end
