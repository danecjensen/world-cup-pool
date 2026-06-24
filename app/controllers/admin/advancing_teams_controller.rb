class Admin::AdvancingTeamsController < Admin::BaseController
  def show
    @r32_matches = KnockoutMatch.where(round: "r32")
                                .includes(:home_team, :away_team)
                                .order(:bracket_position)
    # All 48 teams, grouped by their group letter so the picker can offer
    # tidy <optgroup>s (e.g. "Group A › Mexico").
    @teams = Team.includes(:group).alphabetical
    @grouped_team_options = Group.order(:letter).map do |group|
      ["Group #{group.letter}", @teams.select { |t| t.group_id == group.id }.map { |t| ["#{t.flag_emoji} #{t.name}", t.id] }]
    end
  end

  def update
    assignments = params.fetch(:matches, {})
    KnockoutMatch.transaction do
      KnockoutMatch.where(round: "r32").find_each do |km|
        data = assignments[km.id.to_s]
        next unless data
        km.update!(
          home_team_id: data[:home_team_id].presence,
          away_team_id: data[:away_team_id].presence
        )
      end
    end

    # Re-propagate so the rest of the bracket (R16+) and any scoring stays in
    # sync with the newly entered Round-of-32 teams.
    ScoringService.recompute_all

    redirect_to admin_advancing_teams_path,
                notice: "Round of 32 bracket saved — players now see real team names in every matchup."
  end
end
