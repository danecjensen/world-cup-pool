class KnockoutMatch < ApplicationRecord
  ROUNDS = %w[r32 r16 qf sf final].freeze
  ROUND_POINTS = { "r32" => 2, "r16" => 3, "qf" => 4, "sf" => 5, "final" => 6 }.freeze
  ROUND_NAMES = {
    "r32" => "Round of 32",
    "r16" => "Round of 16",
    "qf"  => "Quarterfinal",
    "sf"  => "Semifinal",
    "final" => "Final"
  }.freeze

  belongs_to :home_slot, class_name: "BracketSlot", optional: true
  belongs_to :away_slot, class_name: "BracketSlot", optional: true
  belongs_to :winner_slot, class_name: "BracketSlot", optional: true
  belongs_to :home_team, class_name: "Team", optional: true
  belongs_to :away_team, class_name: "Team", optional: true
  belongs_to :winner_team, class_name: "Team", optional: true
  has_many :picks, dependent: :destroy

  validates :number, presence: true, uniqueness: true
  validates :round, inclusion: { in: ROUNDS }

  scope :ordered, -> { order(:number) }
  scope :by_round, ->(r) { where(round: r).order(:bracket_position) }

  def round_name
    ROUND_NAMES[round]
  end

  def points_value
    ROUND_POINTS[round]
  end

  def first_r32_kickoff?
    round == "r32"
  end
end
