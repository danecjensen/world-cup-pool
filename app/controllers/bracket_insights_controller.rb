class BracketInsightsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_knockout_access!

  # A read-only, crowd-sourced view of the knockout bracket: for every match it
  # shows what share of players picked each team to win it. Because picks for the
  # later rounds depend on each player's own upstream choices, the set of teams a
  # match attracts is itself interesting — it surfaces the pool's consensus path
  # to the trophy.
  def show
    @rounds = KnockoutMatch::ROUNDS
    @matches_by_round = KnockoutMatch.includes(:home_slot, :away_slot, :home_team, :away_team)
                                     .order(:bracket_position).group_by(&:round)

    # Showing how the field picked before picks lock would let latecomers copy
    # the crowd, so the numbers stay hidden until the bracket locks. Admins can
    # always preview to sanity-check the page.
    @reveal = knockout_stage_locked? || admin_user?
    return unless @reveal

    teams_by_id = Team.all.index_by(&:id)

    # knockout_match_id + team_id => number of players who picked that team to win.
    counts = Pick.where.not(knockout_match_id: nil)
                 .where.not(team_id: nil)
                 .group(:knockout_match_id, :team_id)
                 .count

    grouped = Hash.new { |h, k| h[k] = [] }
    counts.each { |(km_id, team_id), count| grouped[km_id] << [team_id, count] }

    # km_id => { total: pickers, teams: [{ team:, count:, pct: } ...] desc }
    @distribution = {}
    grouped.each do |km_id, pairs|
      total = pairs.sum { |_, count| count }
      teams = pairs.filter_map do |team_id, count|
        team = teams_by_id[team_id]
        next unless team
        { team: team, count: count, pct: (100.0 * count / total).round }
      end.sort_by { |row| -row[:count] }
      @distribution[km_id] = { total: total, teams: teams }
    end

    # The single final match doubles as the pool's "who wins it all" poll.
    final_match = @matches_by_round["final"]&.first
    @champion = final_match && @distribution[final_match.id]
    @total_bracketeers = Pick.where.not(knockout_match_id: nil).distinct.count(:user_id)
  end

  private

  # Mirror the bracket-picks gate: the section is behind a feature flag, and
  # while it's off only admins may reach it to test.
  def require_knockout_access!
    return if knockout_visible?

    redirect_to root_path, alert: "The knockout bracket isn't open yet — check back soon!"
  end
end
