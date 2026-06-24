class GroupPicksController < ApplicationController
  before_action :authenticate_user!

  def show
    @groups = Group.includes(matches: [:home_team, :away_team]).order(:letter)
    @picks_by_match = current_user.picks.where.not(match_id: nil).index_by(&:match_id)
    @locked = group_stage_locked?

    # How the whole pool picked each group game, so we can show what percentage
    # of pickers backed each option. Only users who actually submitted a pick
    # for a match count toward that match's denominator.
    @group_pick_counts = Pick.where.not(match_id: nil)
                             .where.not(group_result: nil)
                             .group(:match_id, :group_result)
                             .count
    @group_pick_totals = Hash.new(0)
    @group_pick_counts.each { |(match_id, _result), count| @group_pick_totals[match_id] += count }
  end

  def update
    if group_stage_locked?
      redirect_to group_picks_path, alert: "Group stage picks are locked — the first match has already kicked off."
      return
    end

    submitted = params.fetch(:picks, {})
    Pick.transaction do
      submitted.each do |match_id, result|
        next if result.blank?
        next unless Match::RESULTS.include?(result)
        match = Match.find_by(id: match_id)
        next unless match
        pick = current_user.picks.find_or_initialize_by(match_id: match.id)
        pick.group_result = result
        pick.save!
      end
    end

    redirect_to group_picks_path, notice: "Group picks saved."
  end
end
