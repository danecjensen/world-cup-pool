class BracketPicksController < ApplicationController
  before_action :authenticate_user!

  def show
    @rounds = KnockoutMatch::ROUNDS
    @matches_by_round = KnockoutMatch.includes(:home_slot, :away_slot, :home_team, :away_team).ordered.group_by(&:round)
    @picks_by_km = current_user.picks.where.not(knockout_match_id: nil).index_by(&:knockout_match_id)
    @group_stage_locked = group_stage_locked?
    @knockout_locked = knockout_stage_locked?
    @group_stage_complete = Match.where(result: nil).none?
  end

  def update
    if knockout_stage_locked?
      redirect_to bracket_picks_path, alert: "Bracket picks are locked — the first R32 match has already kicked off."
      return
    end

    submitted = params.fetch(:picks, {})
    Pick.transaction do
      submitted.each do |km_id, team_id|
        next if team_id.blank?
        km = KnockoutMatch.find_by(id: km_id)
        next unless km
        team = Team.find_by(id: team_id)
        next unless team
        pick = current_user.picks.find_or_initialize_by(knockout_match_id: km.id)
        pick.team = team
        pick.save!
      end
    end

    redirect_to bracket_picks_path, notice: "Bracket picks saved."
  end
end
