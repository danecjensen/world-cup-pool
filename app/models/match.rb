class Match < ApplicationRecord
  RESULTS = %w[home draw away].freeze

  belongs_to :group
  belongs_to :home_team, class_name: "Team"
  belongs_to :away_team, class_name: "Team"
  has_many :picks, dependent: :destroy

  validates :number, presence: true, uniqueness: true
  validates :result, inclusion: { in: RESULTS, allow_nil: true }

  scope :ordered, -> { order(:kickoff_at, :number) }
  scope :finished, -> { where.not(result: nil) }

  def finished?
    result.present?
  end

  def locked?
    kickoff_at.present? && kickoff_at <= Time.current
  end

  def derive_result
    return nil if home_score.nil? || away_score.nil?
    return "home" if home_score > away_score
    return "away" if away_score > home_score
    "draw"
  end
end
