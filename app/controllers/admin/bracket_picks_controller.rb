# Lets an admin fill in or fix a player's knockout bracket on their behalf
# (some players submit picks over email). Every pick an admin creates or
# changes here is flagged admin_entered so it shows up on the audit page —
# these edits move real standings, so they need a paper trail.
class Admin::BracketPicksController < Admin::BaseController
  before_action :set_pick_user

  def show
    @rounds = KnockoutMatch::ROUNDS
    @matches_by_round = KnockoutMatch.includes(:home_slot, :away_slot, :home_team, :away_team)
                                     .order(:bracket_position).group_by(&:round)
    @picks_by_km = @pick_user.picks.where.not(knockout_match_id: nil).index_by(&:knockout_match_id)
    @admin_entered_count = @picks_by_km.values.count(&:admin_entered?)
    @knockout_locked = knockout_stage_locked?
  end

  def update
    submitted = params.fetch(:picks, {})
    Pick.transaction do
      submitted.each do |km_id, team_id|
        km = KnockoutMatch.find_by(id: km_id)
        next unless km
        pick = @pick_user.picks.find_by(knockout_match_id: km.id)

        # A blank value means the slot is empty or the pick was invalidated by an
        # upstream change — clear any saved pick for this match.
        if team_id.blank?
          pick&.destroy
          next
        end

        team = Team.find_by(id: team_id)
        next unless team
        pick ||= @pick_user.picks.build(knockout_match_id: km.id)
        pick.team = team
        # Only flag picks the admin actually created or changed — resubmitting
        # the player's own untouched picks must not mark them admin-entered.
        pick.admin_entered = true if pick.new_record? || pick.changed?
        pick.save!
      end
    end

    redirect_to admin_user_bracket_picks_path(@pick_user),
                notice: "Bracket picks saved for #{@pick_user.display_name}. Anything you added or changed is flagged as admin-entered."
  end

  private

  def set_pick_user
    @pick_user = User.find(params[:user_id])
  end
end
