class ScoringService
  GROUP_POINTS = 1

  def self.recompute_all
    new.recompute_all
  end

  def recompute_all
    Pick.update_all(correct: false, points_awarded: 0)
    score_group_picks
    resolve_bracket_slots
    score_knockout_picks
  end

  def score_group_picks
    Match.finished.includes(:picks).find_each do |match|
      match.picks.find_each do |pick|
        correct = pick.group_result.present? && pick.group_result == match.result
        pick.update_columns(
          correct: correct,
          points_awarded: correct ? GROUP_POINTS : 0
        )
      end
    end
  end

  def resolve_bracket_slots
    # Round-of-32 teams are entered by hand on the admin "advancing teams"
    # page (we deliberately do NOT auto-fill them from group standings).
    # Here we only propagate whatever teams are on the slots onto the matches
    # and advance the winner of each finished match into the next round.
    KnockoutMatch.ordered.each do |km|
      km.update!(
        home_team: km.home_slot&.team,
        away_team: km.away_slot&.team
      )

      next if km.home_score.nil? || km.away_score.nil?
      winner = km.home_score > km.away_score ? km.home_team : km.away_team
      next if winner.nil?
      km.update!(winner_team: winner)
      # Drop the winner into the slot that feeds the next round so the bracket
      # advances automatically (e.g. an R32 winner appears in its R16 match).
      km.winner_slot&.update!(team: winner) if km.winner_slot
    end
  end

  def score_knockout_picks
    KnockoutMatch.where.not(winner_team_id: nil).includes(:picks).find_each do |km|
      km.picks.find_each do |pick|
        correct = pick.team_id.present? && pick.team_id == km.winner_team_id
        pick.update_columns(
          correct: correct,
          points_awarded: correct ? km.points_value : 0
        )
      end
    end
  end
end
