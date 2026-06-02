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
    Group.find_each do |group|
      matches = group.matches.to_a
      next unless matches.all?(&:finished?)
      standings = compute_group_standings(group, matches)
      [1, 2, 3].each do |pos|
        slot = BracketSlot.find_by(code: "#{pos}#{group.letter}")
        slot&.update!(team: standings[pos - 1])
      end
    end

    KnockoutMatch.ordered.each do |km|
      km.update!(
        home_team: km.home_slot&.team,
        away_team: km.away_slot&.team
      )

      next if km.home_score.nil? || km.away_score.nil?
      winner = km.home_score > km.away_score ? km.home_team : km.away_team
      next if winner.nil?
      km.update!(winner_team: winner)
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

  private

  def compute_group_standings(group, matches)
    table = group.teams.each_with_object({}) do |team, h|
      h[team.id] = { team: team, pts: 0, gd: 0, gf: 0 }
    end

    matches.each do |m|
      next if m.home_score.nil? || m.away_score.nil?
      h, a = m.home_team_id, m.away_team_id
      table[h][:gf] += m.home_score; table[a][:gf] += m.away_score
      table[h][:gd] += (m.home_score - m.away_score)
      table[a][:gd] += (m.away_score - m.home_score)
      case m.result
      when "home" then table[h][:pts] += 3
      when "away" then table[a][:pts] += 3
      when "draw" then table[h][:pts] += 1; table[a][:pts] += 1
      end
    end

    table.values
         .sort_by { |row| [-row[:pts], -row[:gd], -row[:gf], row[:team].name] }
         .map { |row| row[:team] }
  end
end
