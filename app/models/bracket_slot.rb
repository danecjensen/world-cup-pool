class BracketSlot < ApplicationRecord
  belongs_to :team, optional: true

  validates :code, presence: true, uniqueness: true
  validates :source_type, inclusion: { in: %w[group_position match_winner] }

  def display_label
    return team.name if team.present?
    case source_type
    when "group_position"
      case position
      when 1 then "1st #{group_letter}"
      when 2 then "2nd #{group_letter}"
      when 3 then "3rd #{group_letter}"
      else code
      end
    when "match_winner"
      "Winner of match #{source_match_id}"
    else
      code
    end
  end
end
