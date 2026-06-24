class Admin::AdvancingTeamsController < Admin::BaseController
  # Human label for each group-finishing position.
  POSITION_LABELS = { 1 => "Winner · 1st", 2 => "Runner-up · 2nd", 3 => "3rd place" }.freeze

  def show
    @groups = Group.order(:letter)
    @teams_by_group = Team.includes(:group).alphabetical.group_by(&:group_id)
    @slots_by_group = group_position_slots.includes(:team).order(:position).group_by(&:group_letter)
  end

  def update
    assignments = params.fetch(:slots, {})
    BracketSlot.transaction do
      assignments.each do |slot_id, team_id|
        slot = group_position_slots.find_by(id: slot_id)
        next unless slot
        slot.update!(team_id: team_id.presence)
      end
    end

    # Propagate the slot teams onto the R32 knockout matches so users see real
    # team names instead of "1A" placeholders.
    ScoringService.recompute_all

    redirect_to admin_advancing_teams_path,
                notice: "Advancing teams saved — the bracket now shows real team names."
  end

  private

  def group_position_slots
    BracketSlot.where(source_type: "group_position")
  end
end
