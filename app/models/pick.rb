class Pick < ApplicationRecord
  belongs_to :user
  belongs_to :match, optional: true
  belongs_to :knockout_match, optional: true
  belongs_to :bracket_slot, optional: true
  belongs_to :team, optional: true

  validates :group_result, inclusion: { in: Match::RESULTS, allow_nil: true }
  validate :exactly_one_target

  private

  def exactly_one_target
    if match_id.present? && knockout_match_id.present?
      errors.add(:base, "pick cannot target both a group match and a knockout match")
    elsif match_id.nil? && knockout_match_id.nil?
      errors.add(:base, "pick must target either a group match or a knockout match")
    end
  end
end
