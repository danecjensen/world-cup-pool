class Pick < ApplicationRecord
  belongs_to :user
  belongs_to :match, optional: true
  belongs_to :knockout_match, optional: true
  belongs_to :bracket_slot, optional: true
  belongs_to :team, optional: true

  validates :group_result, inclusion: { in: Match::RESULTS, allow_nil: true }
  validate :exactly_one_target

  # Columns used when exporting picks to CSV from the developer tools. Instead of
  # dumping raw foreign keys and the home/away/draw enum, this surfaces the
  # picker's identity, the match name, and the team the user actually picked.
  CSV_EXPORT_COLUMNS = %w[
    id username email match selection
    points_awarded correct created_at updated_at
  ].freeze

  def self.csv_export_columns
    CSV_EXPORT_COLUMNS
  end

  def self.csv_export_scope(scope)
    scope.includes(
      :user,
      :team,
      match: [:home_team, :away_team],
      knockout_match: [:home_team, :away_team, :home_slot, :away_slot]
    )
  end

  def csv_export_row
    {
      "id" => id,
      "username" => user&.display_name,
      "email" => user&.email,
      "match" => match_label,
      "selection" => selection_label,
      "points_awarded" => points_awarded,
      "correct" => correct,
      "created_at" => created_at,
      "updated_at" => updated_at
    }
  end

  # e.g. "Mexico vs South Africa"
  def match_label
    if match
      "#{team_name(match.home_team)} vs #{team_name(match.away_team)}"
    elsif knockout_match
      home = team_name(knockout_match.home_team) || knockout_match.home_slot&.code
      away = team_name(knockout_match.away_team) || knockout_match.away_slot&.code
      "#{home} vs #{away}"
    end
  end

  # The team the user picked, instead of the raw home/away/draw enum.
  def selection_label
    if match && group_result.present?
      case group_result
      when "home" then team_name(match.home_team)
      when "away" then team_name(match.away_team)
      when "draw" then "Draw"
      end
    elsif team
      team_name(team)
    end
  end

  private

  def team_name(team_record)
    team_record&.name
  end

  def exactly_one_target
    if match_id.present? && knockout_match_id.present?
      errors.add(:base, "pick cannot target both a group match and a knockout match")
    elsif match_id.nil? && knockout_match_id.nil?
      errors.add(:base, "pick must target either a group match or a knockout match")
    end
  end
end
